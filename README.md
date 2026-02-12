# SafeBite — Your AI Allergy Guardian

# SafeBite
### Your AI Allergy Guardian

**Scan any menu. Eat with confidence.**

Built with Flutter + Claude AI

> *"Because 'I'll just have water' shouldn't be your default order."*

---

## The Problem

### 32 Million Americans Have Food Allergies. Eating Out Is a Gamble.

- Menus **don't list every ingredient** — Pad Thai doesn't say "contains peanuts, fish sauce, eggs, soy"
- **Cross-contamination risks** are invisible to diners
- **Language barriers** make it nearly impossible to ask the right questions abroad
- **One wrong bite** can mean anaphylaxis — restaurant reactions account for ~50% of fatal cases

### Who suffers?

| Audience | Pain Point |
|---|---|
| Allergy sufferers (32M Americans) | Fear of hidden ingredients every time they eat out |
| Parents of allergic children | Managing multiple allergens across school trips, birthday parties, restaurants |
| International travelers | Can't read menus, can't communicate allergies to staff |

**There's no app that combines menu scanning with AI-powered allergen inference. Until now.**

---

## What SafeBite Does

### Point. Scan. Know.

```
  1. SET UP YOUR PROFILE          2. PHOTOGRAPH ANY MENU
  ┌───────────────────┐           ┌───────────────────┐
  │  What are you     │           │                   │
  │  allergic to?     │           │   [Any language]   │
  │                   │           │   [Any cuisine]    │
  │  🥜 🥛 🥚 🌾 🫘  │           │   [Multi-page]     │
  │  🐟 🦐 🌰 ...    │           │                   │
  │                   │           │       📸           │
  │  Severity: ●●○    │           │                   │
  └───────────────────┘           └───────────────────┘

  3. GET INSTANT RESULTS           4. TAP FOR DETAILS
  ┌───────────────────┐           ┌───────────────────┐
  │ 4 safe · 2 ⚠ · 1!│           │ 🔴 DANGER         │
  │                   │           │ Pad Thai           │
  │ 🟢 Caesar Salad   │           │                   │
  │ 🟡 Margherita     │           │ Confirmed: peanuts │
  │ 🔴 Pad Thai       │           │ Likely: fish, egg  │
  │ 🟢 Grilled Fish   │           │ Possible: shellfish│
  │ ...               │           │                   │
  └───────────────────┘           │ 💬 Ask your waiter │
                                  │ 🔄 Substitutions   │
                                  └───────────────────┘
```

**Key features:**
- **15 allergen types** + custom allergens, each with severity levels (mild / moderate / severe)
- **Traffic-light color coding**: Green (safe), Yellow (caution), Red (danger)
- **3-tier allergen analysis**: Confirmed, Likely, Possible (cross-contamination)
- **AI-generated waiter questions** specific to each dish
- **Substitution suggestions** — "Ask for tamari instead of soy sauce"
- **Emergency allergy card** — show staff your profile at a glance
- **Shareable results** — branded image export for dining companions

---

## Why SafeBite Matters

### This App Can Save Lives

**The gap in the market:**

| Existing Solutions | What's Missing |
|---|---|
| Googling ingredients manually | Slow, misses inferred/hidden allergens |
| Asking the waiter | Language barriers, untrained staff, social anxiety |
| Allergy translation cards | Static — can't analyze a specific menu |
| Food diary apps | Reactive (after eating), not preventive |

**SafeBite is the first app that:**
- Infers **hidden ingredients** the menu doesn't list (e.g., fish sauce in Thai cuisine)
- Considers **cross-contamination** based on kitchen type
- Provides a **confidence score** so you know when to trust the AI vs. ask the waiter
- Is **conservative by design** — when in doubt, it flags caution, not safe

**Impact by the numbers:**
- Food allergies affect **1 in 10 adults** and **1 in 13 children** in the US
- Emergency room visits for food allergies: **200,000+ per year**
- Restaurant-related anaphylaxis fatalities: **~150 per year** in the US

---

## Technical Architecture

### Four-Layer Pipeline: Image --> Text --> AI --> Results

```
┌─────────────────────────────────────────────────────────────┐
│                      CAMERA / GALLERY                        │
│                       (image_picker)                         │
│              Supports multi-page menu capture                │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  IMAGE PREPROCESSING                         │
│          Resize --> Grayscale --> Contrast --> Sharpen        │
│                    (image package)                           │
│         Optimizes dim/blurry restaurant photos               │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    ON-DEVICE OCR                              │
│             Google ML Kit Text Recognition                    │
│          Runs locally -- no server, no latency               │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                AI ALLERGEN ANALYSIS                           │
│           Claude Sonnet 4.5 (streaming SSE)                  │
│        Haiku 4.5 automatic fallback on failure               │
│      Returns structured JSON with risk assessments           │
└──────────────────────────┬──────────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  TRAFFIC LIGHT RESULTS                        │
│          🟢 Safe  ·  🟡 Caution  ·  🔴 Danger               │
│       + Confidence % + Substitutions + Waiter Questions      │
└─────────────────────────────────────────────────────────────┘
```

### Tech Stack

| Layer | Technology | Why |
|---|---|---|
| Framework | **Flutter 3.x** | Single codebase for iOS + Android |
| State | **Riverpod** | Reactive state with dependency injection |
| OCR | **Google ML Kit** | On-device (privacy-first, no server needed) |
| AI | **Claude API** | Best-in-class reasoning for ingredient inference |
| Storage | **Hive** | Fast, type-safe NoSQL for local persistence |
| Navigation | **GoRouter** | Declarative routing with deep linking |
| UI | **Material Design 3** | Modern, accessible, beautiful |
| Animations | **Lottie** | Smooth loading animations |

**Codebase:** 29 Dart files | ~27,500 lines | 46 tests

---

## The AI Brain — Prompt Engineering

### The LLM Doesn't Just Read the Menu — It Thinks Like a Chef

**The prompt instructs Claude to be a food allergy safety expert:**

```
1. ANALYZE every menu item against the user's specific allergen profile
2. INFER hidden ingredients
   --> "Pad Thai traditionally contains fish sauce, egg, and soy sauce
       — even if not listed on the menu"
3. CONSIDER cross-contamination
   --> "Thai kitchens commonly have shellfish cross-contamination"
4. BE CONSERVATIVE
   --> "When in doubt, flag it as CAUTION rather than SAFE"
5. GENERATE actionable advice
   --> "Can this be made without peanuts? Does the fish sauce
       contain shellfish?"
```

**Structured JSON response per menu item:**

```json
{
  "name": "Pad Thai",
  "risk_level": "danger",
  "confidence": 92,
  "confirmed_allergens": ["peanuts"],
  "likely_allergens": ["fish", "eggs", "soy"],
  "possible_allergens": ["shellfish"],
  "explanation": "Pad Thai traditionally contains crushed peanuts,fish sauce, egg, and soy sauce...",
  "waiter_question": "Can this be made without peanuts?Does the fish sauce contain shellfish?",
  "substitution_suggestions": ["Ask for no peanuts",
                                "Request tamari instead of soy sauce"]
}
```

**Resilient 3-stage JSON parsing:**
1. Direct JSON decode
2. Strip markdown code fences (if Claude wraps the response)
3. Regex extraction as last resort

*The AI never fails silently — it always delivers results.*

---

## Wow Factor #1 — Image Preprocessing Pipeline

### Before OCR Sees the Image, It's Been Optimized for Text Recognition

**The problem:** Restaurant menus are photographed in dim lighting, at awkward angles, with decorative fonts. Raw photos produce terrible OCR.

**The solution:** A 4-step preprocessing pipeline:

```
  RAW PHOTO         RESIZE           GRAYSCALE        CONTRAST +30%      SHARPEN
  ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐
  │ 📷 dim  │ ---> │ ≤2000px │ ---> │ B&W for │ ---> │ Text    │ ---> │ Crisp   │
  │ blurry  │      │ optimal │      │ contrast│      │ pops    │      │ edges   │
  │ angled  │      │ for OCR │      │         │      │         │      │         │
  └─────────┘      └─────────┘      └─────────┘      └─────────┘      └─────────┘
```

**Implementation:**

```dart
// Convert to grayscale for better text contrast
processed = img.grayscale(processed);

// Increase contrast to make text stand out
processed = img.adjustColor(processed, contrast: 1.3);

// Sharpen text edges with convolution kernel
processed = img.convolution(processed, [
  0, -1, 0,
  -1,  5, -1,
  0, -1, 0,
]);
```

**The convolution kernel** is a classic Laplacian sharpening filter — the center pixel (5) is emphasized while surrounding pixels (-1) sharpen edges. This dramatically improves OCR accuracy on real-world menu photos.

> *"It's like putting on reading glasses... for your phone."*

---

## Wow Factor #2 — Streaming + Automatic Fallback

### Two Resilience Patterns in One Feature

**Pattern 1: Streaming SSE (Server-Sent Events)**

Instead of waiting for the full AI response (blank loading screen), users see progress in real-time:

```
  "Reading menu..."  -->  "Analyzing ingredients..."  -->  Results appear one by one
       ⏳ 0s                    ⏳ 3s                          ⏳ 5s+
```

Custom SSE parser handles Claude API's streaming protocol — accumulates `content_block_delta` events and yields partial results as they arrive.

**Pattern 2: Automatic Model Fallback**

```dart
Stream<StreamingUpdate> analyzeMenuWithFallback(...) async* {
  try {
    // Try the powerful model first (45-second timeout)
    yield* _streamFromModel(prompt, 'claude-sonnet-4-5', timeout: 45s);
  } catch (e) {
    // If it fails, seamlessly retry with the faster model
    yield StreamingUpdate(status: 'Retrying with faster model...');
    yield* _streamFromModel(prompt, 'claude-haiku-4-5', timeout: 30s);
  }
}
```

**Result:** The user *always* gets an answer. If the primary model (Sonnet) times out or errors, the app automatically retries with Haiku. The user just sees "Retrying with faster model..." — no crash, no error screen, no frustration.

> *"Like having a backup chef in the kitchen — dinner is always served."*

---

## Wow Factor #3 — Traffic Light UX + Haptic Feedback

### Every Sense Is Engaged — Sight, Touch, and Action

**Consistent visual language across every screen:**

| Element | Safe | Caution | Danger |
|---|---|---|---|
| Color | `#2E7D32` (green) | `#F57F17` (amber) | `#C62828` (red) |
| Icon | check_circle | warning_amber | dangerous |
| Haptic | Light tap | Medium pulse | **Heavy vibration** |

**Your phone physically vibrates differently based on risk:**

```dart
if (result.dangerCount > 0) {
  HapticFeedback.heavyImpact();   // Phone SHAKES -- danger detected!
} else if (result.cautionCount > 0) {
  HapticFeedback.mediumImpact();  // Gentle pulse -- proceed with caution
} else {
  HapticFeedback.lightImpact();   // Soft tap -- all clear!
}
```

**Confidence scoring with color-coded transparency:**
- **90%+** confidence = green text ("We're sure about this")
- **70-89%** = amber text ("Likely, but ask to be safe")
- **<70%** = red text ("AI is uncertain — definitely ask the waiter!")

**Emergency Allergy Card:**
- Full-screen card with "FOOD ALLERGY ALERT" header
- Allergens grouped by severity with colored pills and emojis
- Shareable as a high-res image (3x pixel ratio)
- Perfect for handing your phone to a waiter who doesn't speak your language

**Hero animations** provide smooth transitions between the results list and detail views, making the app feel native and polished.

> *"The only app that warns you with a literal shake."*

---

## By the Numbers + What's Next

### Built in a Hackathon Sprint

| Metric | Value |
|---|---|
| Dart files | 29 |
| Lines of code | ~27,500 |
| Tests | 46 (unit + widget) |
| Allergen types | 15 + custom |
| Risk levels | 3 (safe / caution / danger) |
| AI models | 2 (Sonnet primary + Haiku fallback) |
| Platforms | iOS + Android (single codebase) |
| JSON parsing fallbacks | 3 stages |
| Preprocessing steps | 4 stages |

### What's Next

| Feature | Impact |
|---|---|
| Live camera OCR preview | Real-time text overlay while aiming at menu |
| Barcode scanning | Packaged food allergen detection |
| Multi-profile support | Parents managing kids' allergy profiles |
| Apple Watch alerts | Wearable danger push notifications |
| Crowdsourced accuracy | Community-reported ingredient corrections |
| Restaurant partnerships | Verified ingredient lists from restaurants |

---

### SafeBite: Because everyone deserves to eat without fear.

**Point. Scan. Know.**

---

*Built with Flutter, Google ML Kit, Anthropic Claude API, Riverpod, Hive, and a whole lot of empathy for people who just want to enjoy a meal out.*
