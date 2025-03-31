import { useEffect, useState } from "react";
import { StyleSheet, Text, TextInput, View } from "react-native";
import eliteClubs from "@/requests/getClubsList";

export default function Index() {
  const [clubs, setClubs] = useState([]);
  const [filter, setFilter] = useState();

  useEffect(() => {
    

    eliteClubs(filter, 100000000, 10).then(
      (clubs) => {
        console.log('clubs', clubs);
        setClubs(clubs);
      }
    );
  }, [filter]);

  const onChange = (event) => {
    const value = event.target.value;

    setFilter(value);
  }
  
  return (
    <View
      style={styles.wrapper}
    >
      <TextInput onChange={onChange} value={filter} />
      {
        clubs?.map(
          (club) => {
            return <Text>{club}</Text>;
          }
        )
      }
      <Text>Edit app/index.tsx to edit this screen.</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  }
})
