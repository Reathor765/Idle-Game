MVP Goal: The First Replication
The primary goal of the MVP is to build and validate the core gameplay loop: Fabricate -> Build -> Replicate. The player should be able to start in their first system (Sol), build up enough infrastructure to construct a Replicant Vessel, and launch it to a new star system. This will prove the core prestige mechanic is engaging and that the multi-system management is technically sound.

MVP Development Roadmap
This roadmap is broken into three logical phases.

Phase 1: Foundation & The First System (Weeks 1-4)
Focus: Establishing the core mechanics within a single star system.

Game State Management:

Create the core data structures for managing player progress. In Godot, this would be ideal as a custom Resource (PlayerData.tres) that can hold dictionaries for resources, upgrade levels, and system states.
player_data = { "resources": {"metals": 100, "polymers": 50}, "systems": {"Sol": {...}} }
Resource Generation System:

Implement the basic logic for infrastructure (e.g., "Fabricator Mk. I") to generate resources over time.
Create a global "tick" manager that calculates income per second and updates the player's resources.
Basic System View UI:

Develop the main game screen for a single system.
UI elements to display current resource counts and income per second.
Placeholders for buildable slots on a planet.
Build & Upgrade System:

Implement the logic for spending resources to build new infrastructure.
Allow players to upgrade existing structures (e.g., Fabricator Mk. I -> Mk. II) for increased efficiency.
Simple Offline Progress:

On game close, save a timestamp.
On game load, calculate the time elapsed and grant resources based on the player's income-per-second. The MVP can cap this at 2 hours.
Phase 2: The Core Loop & Expansion (Weeks 5-8)
Focus: Implementing the prestige mechanic and expanding the game beyond a single screen.

Replication Vessel Project:

Define a multi-stage construction project that serves as the goal for the first prestige. This will require a large number of resources.
Replication Mechanic (Prestige):

When the vessel is complete, trigger the "Replication" event.
This should not reset the first system. Instead, it adds a new, fresh system to the player's PlayerData.
Galaxy Map UI:

Create a simple, functional map screen.
It must display the player's controlled systems (Sol and the new one).
Allow the player to tap on a system to switch to its "System View".
Multi-System Management Backend:

Refactor the resource generation system to calculate total income from all controlled systems.
Ensure the player's global resource pool is correctly updated by all "Bobs" simultaneously.
Global Engineering Upgrades:

Implement a basic upgrade panel with a few key upgrades that affect all systems (e.g., "+10% Fabrication Speed," "-5% Build Cost"). This demonstrates the benefit of a unified empire.
Phase 3: Polish & MVP Release Candidate (Weeks 9-12)
Focus: Bringing the core loop up to a releasable quality standard.

UI/UX Polish & Feedback:

Add satisfying sound effects and simple particle effects for building, upgrading, and collecting resources.
Ensure the UI is clean, readable, and intuitive.
Implement standard notation for large numbers (K, M, B, T).
Initial Game Balancing:

First pass on all costs, generation rates, and upgrade effects.
The goal is for the first replication to take a reasonable amount of time (e.g., 1-3 days of casual play) to feel like a significant achievement.
Onboarding/Tutorial:

Create a simple, non-intrusive tutorial that guides the player through building their first Fabricator and explains the goal of building the Replicant Vessel.
Robust Local Saves:

Finalize the save/load system.
Implement a backup save slot to prevent players from losing progress due to file corruption.
Monetization Hooks:

Integrate the code for a single rewarded ad type (e.g., "Supply Drop" to get 2 hours of resources). This is to test the technical implementation and player interaction, even if full monetization is not yet active.
What is NOT in the MVP (Post-MVP Features)
To maintain a tight scope, the following features from the PRD will be developed after the MVP is validated:

Alien Encounters & Combat System: This is a major expansion.
Reverse Engineering & Alien Tech Tree: The entire meta-prestige layer.
Points of Interest & Random Events: Adds flavor and depth, but not core to the loop.
Full Monetization Suite: IAPs, premium currency (Exa-cores), and multiple ad placements.
Cloud Saves: Critical for long-term retention, but complex to implement. Local saves are sufficient for an MVP.
Advanced Content: Additional infrastructure types, deeper upgrade chains, different planet types, etc.