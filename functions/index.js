const admin = require("firebase-admin");
const {GoogleGenerativeAI} = require("@google/generative-ai");
const {defineSecret} = require("firebase-functions/params");
const {HttpsError, onCall} = require("firebase-functions/v2/https");

admin.initializeApp();

const geminiApiKey = defineSecret("GEMINI_API_KEY");
const region = "us-central1";
// Gemini is called only from Firebase Cloud Functions. The API key is read
// from the Firebase Secret GEMINI_API_KEY; Flutter never stores the key or
// calls Gemini directly.
const modelName = process.env.GEMINI_MODEL || "gemini-3.1-flash";
const rateLimitWindowMs = 60 * 1000;
const rateLimitMaxRequests = 20;

exports.generateMoodPost = aiCallable(async (data) => {
  const mood = requireText(data.mood, "mood", 160);
  const json = await generateJson({
    prompt:
      "Turn this mood into one concise social post. " +
      "Return JSON only: {\"text\":\"...\"}. " +
      "No markdown. Mood: " + mood,
  });
  return {text: cleanText(json.text, 500)};
});

exports.generateSmartReply = aiCallable(async (data) => {
  const commentText = requireText(data.commentText, "commentText", 500);
  const context = arrayOfStrings(data.context, 5, 240);
  const json = await generateJson({
    prompt:
      "Suggest exactly three short, friendly replies to this comment. " +
      "Return JSON only: {\"suggestions\":[\"...\",\"...\",\"...\"]}. " +
      "No markdown. Context: " + context.join(" | ") +
      "\nComment: " + commentText,
  });
  return {suggestions: stringArray(json.suggestions, 3, 160)};
});

exports.generateToneVariants = aiCallable(async (data) => {
  const draft = requireText(data.draft, "draft", 800);
  const json = await generateJson({
    prompt:
      "Rewrite this social post draft into three tone variants: " +
      "Professional, Funny, Emotional. " +
      "Return JSON only: {\"variants\":[{\"tone\":\"Professional\",\"text\":\"...\"}," +
      "{\"tone\":\"Funny\",\"text\":\"...\"},{\"tone\":\"Emotional\",\"text\":\"...\"}]}. " +
      "No markdown. Draft: " + draft,
  });
  const variants = Array.isArray(json.variants) ? json.variants : [];
  return {
    variants: variants.slice(0, 3).map((item) => ({
      tone: cleanText(item && item.tone, 40),
      text: cleanText(item && item.text, 600),
    })).filter((item) => item.tone && item.text),
  };
});

exports.summarizeFeed = aiCallable(async (data) => {
  const posts = arrayOfStrings(data.posts, 10, 400);
  if (posts.length === 0) {
    throw new HttpsError("invalid-argument", "posts is required.");
  }
  const json = await generateJson({
    prompt:
      "Summarize these recent social feed posts into up to five short bullets. " +
      "Return JSON only: {\"summary\":[\"...\",\"...\"]}. No markdown. " +
      "Posts: " + posts.map((post, index) => `${index + 1}. ${post}`).join("\n"),
  });
  return {summary: stringArray(json.summary, 5, 180)};
});

function aiCallable(handler) {
  return onCall(
    {
      region,
      secrets: [geminiApiKey],
      timeoutSeconds: 30,
      memory: "256MiB",
    },
    async (request) => {
      const uid = request.auth && request.auth.uid;
      if (!uid) {
        throw new HttpsError("unauthenticated", "Sign in required.");
      }
      await assertRateLimit(uid);
      return handler(request.data || {});
    },
  );
}

async function assertRateLimit(uid) {
  const reference = admin.firestore().doc(`aiRateLimits/${uid}`);
  const now = Date.now();

  await admin.firestore().runTransaction(async (transaction) => {
    const snapshot = await transaction.get(reference);
    const data = snapshot.exists ? snapshot.data() : {};
    const windowStartedAt = Number(data.windowStartedAt || 0);
    const count = Number(data.count || 0);
    const isFreshWindow = now - windowStartedAt > rateLimitWindowMs;

    if (!isFreshWindow && count >= rateLimitMaxRequests) {
      throw new HttpsError("resource-exhausted", "AI rate limit reached.");
    }

    transaction.set(reference, {
      windowStartedAt: isFreshWindow ? now : windowStartedAt,
      count: isFreshWindow ? 1 : count + 1,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});
  });
}

async function generateJson({prompt}) {
  const key = geminiApiKey.value();
  if (!key) {
    throw new HttpsError("failed-precondition", "Gemini API key is not configured.");
  }

  try {
    const client = new GoogleGenerativeAI(key);
    const model = client.getGenerativeModel({
      model: modelName,
      generationConfig: {
        temperature: 0.7,
        maxOutputTokens: 700,
        responseMimeType: "application/json",
      },
    });
    const result = await model.generateContent(prompt);
    return parseJson(result.response.text());
  } catch (error) {
    console.error("Gemini request failed", error);
    throw new HttpsError("internal", "AI request failed.");
  }
}

function parseJson(value) {
  const text = String(value || "").trim();
  try {
    return JSON.parse(text);
  } catch (error) {
    const match = text.match(/\{[\s\S]*\}/);
    if (!match) {
      throw error;
    }
    return JSON.parse(match[0]);
  }
}

function requireText(value, field, maxLength) {
  const text = cleanText(value, maxLength);
  if (!text) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  return text;
}

function cleanText(value, maxLength) {
  if (typeof value !== "string") {
    return "";
  }
  return value.trim().slice(0, maxLength);
}

function arrayOfStrings(value, maxItems, maxLength) {
  if (!Array.isArray(value)) {
    return [];
  }
  return value
    .map((item) => cleanText(item, maxLength))
    .filter(Boolean)
    .slice(0, maxItems);
}

function stringArray(value, maxItems, maxLength) {
  return arrayOfStrings(value, maxItems, maxLength);
}
