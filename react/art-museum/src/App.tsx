import React, { useState, useCallback } from "react";
import "./App.css";
import SearchHeader from "./components/SearchHeader/SearchHeader";
import ArtItem from "./components/ArtItem/ArtItem";
import { ArtResult } from "./types/types";
import debounce from "./utils/debounce";
import ArtPreview from "./components/ArtPreview/ArtPreview";

function App() {
  const [search, setSearch] = useState("");
  const [searchBy, setSearchBy] = useState("keyword");
  const searchCriteria = ["keyword", "medium", "Century or Culture"];
  const [results, setResults] = useState([]);
  const [previewEnabled, setPreviewEnabled] = useState(false);
  const [previewData, setPreviewData] = useState<ArtResult | null>(null);

  // Debounced API call function
  const debouncedSearch = useCallback(
    debounce((searchTerm: string) => {
      if (!searchTerm.trim()) {
        setResults([]);
        return;
      }

      const apiKey = "2fb38059-3f24-4f47-a0e1-4f037c491b50";
      const apiUrl = "https://api.harvardartmuseums.org";
      const url = `${apiUrl}/object?apikey=${apiKey}&q=${searchTerm}`;

      fetch(url)
        .then((response) => response.json())
        .then((data) => setResults(data.records))
        .catch((error) => {
          console.error("Error fetching data:", error);
          setResults([]);
        });
    }, 500),
    []
  );

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    setSearch(value);

    // Adding debounce to the search to limit API calls
    debouncedSearch(value);
  };

  return (
    <div className="App">
      <SearchHeader
        searchPlaceholder="Search art"
        onSearchChange={handleSearchChange}
        searchValue={search}
      />

      <main>
        <div className="search-results">
          {results.length === 0 && <p>No results found</p>}
          {results.map((result: ArtResult) => (
            <ArtItem
              key={result.id}
              result={result}
              setEnabled={setPreviewEnabled}
              setPreviewData={setPreviewData}
            />
          ))}
        </div>
      </main>
      <ArtPreview
        enabled={previewEnabled}
        setEnabled={setPreviewEnabled}
        data={previewData}
      />
    </div>
  );
}

export default App;
