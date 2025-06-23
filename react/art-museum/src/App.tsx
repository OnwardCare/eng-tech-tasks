import React, { useState } from "react";
import "./App.css";
import SearchHeader from "./components/SearchHeader/SearchHeader";

function App() {
  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    console.log("Search changed", e.target.value);

    const apiKey = "2fb38059-3f24-4f47-a0e1-4f037c491b50";
    const apiUrl = "https://api.harvardartmuseums.org";

    const url = `${apiUrl}/${searchBy}?apikey=${apiKey}&title=${e.target.value}`;

    fetch(url)
      .then((response) => response.json())
      .then((data) => console.log(data));
    setSearch(e.target.value);
  };

  const [search, setSearch] = useState("");
  const [searchBy, setSearchBy] = useState("keyword");
  const searchCriteria = ["Keyword", "object", "Century or Culture"];

  return (
    <div className="App">
      <SearchHeader
        searchPlaceholder="Search art"
        onSearchChange={handleSearchChange}
        searchValue={search}
      />

      <div className="search-options">
        {searchCriteria.map((option) => (
          <label key={option}>
            <input
              type="radio"
              name="searchBy"
              value={option}
              checked={searchBy === option}
              onChange={() => setSearchBy(option)}
            />
            {option}
          </label>
        ))}
      </div>
      <main>
        <h1>Art Museum</h1>
      </main>
    </div>
  );
}

export default App;
