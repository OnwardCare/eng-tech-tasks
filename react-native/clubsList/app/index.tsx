import { Text, View } from "react-native";
import eliteClubs from "@/requests/getClubsList";
import { useState } from "react";

export default function Index() {
  const [clubs, setClubs] = useState([]);
  
  eliteClubs("England", 100000000, 10).then(
    (clubs) => {
      setClubs(clubs);
    }
  );

  return (
    <View
      style={{
        flex: 1,
        justifyContent: "center",
        alignItems: "center",
      }}
    >
      {
        clubs.map(
          (club) => {
            return <Text>{club}</Text>;
          }
        )
      }
      <Text>Edit app/index.tsx to edit this screen.</Text>
    </View>
  );
}
