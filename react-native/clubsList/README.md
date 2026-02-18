# Onward React Native Coding Challenge 🏆

Welcome! This take-home challenge is your chance to show us how you think, structure code, and build delightful mobile experiences. There are no trick questions — we're just excited to see what you come up with.

This is an [Expo](https://expo.dev) project created with [`create-expo-app`](https://www.npmjs.com/package/create-expo-app).

## Get started

1. Install dependencies

   ```bash
   npm install
   ```

2. Start the app

   ```bash
    npx expo start
   ```

That's it — you're ready to build.

## The Challenge

You're building a **Football Teams Explorer** — an app that lets users browse, filter, and explore football clubs from around the world.

### Part 1 — Teams List (Required)

Build a scrollable list of football teams using the following API:
```
GET https://jsonmock.hackerrank.com/api/football_teams
```

Each team in the list should display basic info (name, league titles, estimated value, etc.), and users should be able to filter the list by:

- **Team name** (search)
- **Minimum estimated value**
- **Minimum league titles won**

> The list should always be sorted by team valuation, highest first.

---

### Part 2 — Stadium Distance (Optional)

Add a button to each team card that, when tapped, shows the distance between the user's current location and that team's stadium.

You can resolve stadium coordinates using the [Nominatim geocoding API](https://nominatim.openstreetmap.org):
```
GET https://nominatim.openstreetmap.org/search?q=Elland+Road+Stadium&format=json
```

## What We're Looking For

- Clean, readable code that's easy to navigate
- Sensible component structure and state management
- A UI that feels native and polished (even if simple)
- How you handle edge cases: loading states, empty results, errors

We're not expecting perfection — if you make trade-offs or leave something rough around the edges, just leave a note in the README explaining your thinking. That kind of transparency goes a long way.

Good luck, and have fun with it! ⚽
