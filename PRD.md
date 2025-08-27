# Product Requirements Document: Project Fusion
**Version:** 1.0
**Date:** October 26, 2023
**Author:** Gemini Code Assist and Reathor765 (Concept Pivot: "Bobiverse")

---

## 1. Overview

### 1.1. Product Vision
To create a captivating and deeply strategic idle progression game for mobile devices, inspired by the "We Are Legion (We Are Bob)" book series. The game will challenge players to explore the galaxy as a sentient AI, manage resources across multiple star systems, and "replicate" to expand their presence. The ultimate goal is to encounter and out-tech alien species, ensuring humanity's survival through superior engineering and wit.

### 1.2. Target Audience
*   **Primary:** Players of idle, incremental, clicker, and merge games on iOS and Android who enjoy optimization and long-term goals.
*   **Secondary:** Strategy and simulation gamers looking for a persistent, low-intensity mobile experience that respects their time.

### 1.3. Core Pillars
*   **Satisfying Feedback:** Every action, especially merging, should feel impactful and rewarding.
*   **Deep Progression:** Players should always have a meaningful short-term and long-term goal to strive for.
*   **Exploration and Discovery:** The feeling of pushing into the unknown and finding new challenges and resources should be a core driver.
*   **Strategic Choices:** While an idle game, player decisions in upgrade paths and prestige timing should matter significantly.

---

## 2. Core Gameplay Loop

The central gameplay experience revolves around a repeatable and rewarding loop themed around interstellar exploration and replication.

1.  **Fabricate:** In a controlled star system, players build and upgrade infrastructure (Mines, Fabricators, Probes) which automatically generate **Resources** (e.g., Metals, Polymers, Electronics).
2.  **Build:** Players spend Resources to build more advanced infrastructure, scientific instruments, and eventually, the components for a new replication vessel.
3.  **Replicate (Prestige):** Once a "Replicant Vessel" is complete, the player launches a new copy of themselves (a new "Bob") to a new star system. This new system starts from scratch but contributes to the player's overall galactic empire.
4.  **Accelerate:** Each new system under the player's control acts as another idle generator, massively accelerating resource income and allowing for faster expansion and technological research.

---

## 3. Key Features & Systems

### 3.1. System Management
*   **System View:** Instead of a grid, each controlled star system has a dedicated management screen. This screen shows available planets, asteroid belts, and slots for building infrastructure.
*   **Infrastructure:** Players build and upgrade various structures.
    *   **Fabricators:** Generate base resources. Higher tiers (Mk. II, Mk. III) are more efficient.
    *   **Scanners:** Required to find new resources and points of interest within a system.
    *   **Probes:** Automated drones that can be sent to survey planets or mine asteroids.
*   **Points of Interest:** Scanning a system may reveal random events like resource-rich asteroids, derelict ships to salvage, or primitive life to observe for science points.

### 3.2. Galactic Expansion & Technology

#### 3.2.1. Layer 1: The Bobnet (Main Game)
*   **Engineering Upgrades:** A global upgrade menu where players spend Resources on improvements that affect their entire network of "Bobs".
    *   **Fabrication Speed:** Increase output of all Fabricators.
    *   **Probe Efficiency:** Increase resource yield from automated probes.
    *   **Vessel Construction:** Reduce the cost of building Replicant Vessels.
*   **Prestige: Replication**
    *   **Trigger:** Constructing and launching a "Replicant Vessel" from any controlled system.
    *   **No Reset:** Unlike traditional prestige, this does not reset progress. Instead, it adds a new, independent system to manage, which starts from zero but adds its production to the whole.
    *   **Reward:** A new "Bob" instance in a new star system. The player can switch between managing their different "Bobs" via a Galaxy Map. The number of controlled systems acts as a powerful multiplier for future progression.

#### 3.2.2. Layer 2: Alien Encounters & Reverse Engineering
*   **Unlock Condition:** Unlocked after establishing a certain number of colonies (e.g., 5 systems) and building a Deep Space Scanner.
*   **New Gameplay: Conflict & Discovery:** The player will begin to encounter alien species.
    *   **Combat:** A simplified, automated combat system. Players build defensive and offensive ships. Fleet strength vs. alien fleet strength determines the outcome.
    *   **Reward:** Winning battles or discovering alien ruins yields **Alien Artifacts**.
*   **Reverse Engineering (Tech Tree):** Alien Artifacts are a new resource used in a "Research Lab".
    *   **Research Projects:** Spending Artifacts and time unlocks nodes on a permanent Alien Tech Tree. This is the meta-prestige layer.
    *   *Examples:*
        *   **Exotic Fabrication:** "Unlock new, powerful infrastructure that generates resources more efficiently."
        *   **Graviton Manipulation:** "Dramatically increase scanner range and probe speed."
        *   **Shield Harmonics:** "Provide a massive boost to ship survivability in combat."

### 3.3. Offline Progress
The game will calculate and award resources generated from all controlled systems while the player was offline. The calculation will be based on the total resource-per-second of the entire "Bobnet". The default offline time limit will be 2 hours, extendable via the Alien Tech Tree.

---

## 4. User Interface & Experience (UI/UX)

*   **Clarity and Readability:** The UI must be clean, intuitive, and designed to handle extremely large numbers without becoming cluttered. We will use standard notation for large numbers (K, M, B, T, aa, ab, ac...).
*   **Main Screen:**
    *   The primary view will be the **System View** of the currently selected "Bob".
    *   A top bar will prominently display counts for various Resources and their total income per second.
    *   A bottom bar will contain clear, icon-driven buttons for "Build", "Upgrades", "Galaxy Map", and "Research".
*   **Galaxy Map:** A crucial screen that allows the player to get an overview of their empire and quickly switch between controlling their different "Bobs".
*   **Minimalism:** The background should be a beautiful but non-distracting view of the current star system (e.g., a gas giant, a nebula).

---

## 5. Monetization Strategy

The monetization model will be player-friendly, focusing on optional purchases that accelerate progress or add convenience, never creating a hard paywall, in keeping with the spirit of the source material.

*   **Rewarded Video Ads:**
    *   **Supply Drop:** Watch an ad to instantly receive 2 hours' worth of Resource production. (Cooldown: 4 hours)
    *   **Efficiency Boost:** Watch an ad to double all Resource production for 4 hours.
    *   **Offline Earnings Multiplier:** Upon returning, the player is offered a chance to watch an ad to double or triple the offline earnings they accumulated.
    *   **Research Breakthrough:** Watch an ad to reduce the current research timer by a set amount (e.g., 2 hours).
*   **In-App Purchases (IAP):**
    *   **Premium Currency (Exa-cores):**
        *   Can be used to purchase permanent boosts (e.g., "+10% resource production in all systems," "Start new colonies with a basic fabricator").
        *   Can be used to instantly finish ad cooldowns.
        *   Can be used to buy Alien Artifacts directly, but at an intentionally poor conversion rate to encourage gameplay.
    *   **"Ad-Free" Pack:** A one-time purchase that removes all optional ads and automatically grants their base rewards (e.g., the 2x production boost becomes a permanent passive effect, Time Warps can be claimed for free on cooldown).
    *   **"First Colony" Pack:** A time-limited offer for new players containing a high-value bundle of Exa-cores and permanent boosts.

---

## 6. Technical Requirements

*   **Game Engine:** **Godot 4.5 beta** (or latest stable release at time of development).
    *   **Language:** Primarily **GDScript** for its rapid development and integration with the engine. C# can be considered for specific, performance-critical systems like handling calculations with extremely large numbers if custom libraries are needed.
*   **Platform:** iOS and Android.
*   **Save System:**
    *   **Local Saves:** A robust local save system using Godot's `FileAccess` to write to a JSON or binary file in the `user://` directory. Implement save backups to prevent corruption.
    *   **Cloud Saves:** Integration with a backend service (e.g., Google Play Games, Apple iCloud, or a custom backend like a BaaS) for seamless cross-device play and progress recovery. This is **absolutely critical** given the multi-system nature of the game.
*   **Analytics:** Integrate an analytics service (e.g., Firebase SDK, or a Godot-specific asset) to track key metrics for balancing, monetization tuning, and feature development.

---

## 7. Success Metrics (KPIs)

*   **Retention:** D1, D7, and D30 retention rates. Our goal is to have a strong D7 retention, indicating players are engaging with the first prestige loop.
*   **Engagement:** Average session length and number of sessions per day.
*   **Expansion Rate:** Average time to first Replication. Number of systems controlled per user per week.
*   **Monetization:**
    *   Average Revenue Per Daily Active User (ARPDAU).
    *   IAP conversion rate (%).
    *   Ad engagement rate (% of DAU watching at least one ad).
