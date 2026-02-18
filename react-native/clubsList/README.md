# Welcome to Onward React-Native coding challenge

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

## Coding challenge

You are tasked with building an ultimate solution that will provide comprehensive information about football teams and their ranking. 

The result of your work would be an expo application that would implement the following responsibilities

### Implement generic view with filtering
- list all available football teams and provide basic information about them 
- allow filtering by the following properties: 
   - name
   - min estimated value
   - min league titles won

The results in the list should always be ordered by team valuation

You can use https://jsonmock.hackerrank.com/api/football_teams API to fetch information about teams

### [optional] Measure distance between device location and team stadium

Build a button for every item in the list clicking on which you would display distance to the respective team stadium

To get coordinates of the stadium, you can use nominatim API,
for example: https://nominatim.openstreetmap.org/search?q=Elland+Road+Stadium&format=json





