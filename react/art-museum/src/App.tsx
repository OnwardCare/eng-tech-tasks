import React, { useState, useCallback } from "react";
import "./App.css";
import SearchHeader from "./components/SearchHeader/SearchHeader";
import ArtItem from "./components/ArtItem/ArtItem";
import { ArtResult } from "./types/types";
import debounce from "./utils/debounce";
import ArtPreview from "./components/ArtPreview/ArtPreview";

function App() {
  const [search, setSearch] = useState("");
  const [results, setResults] = useState<ArtResult[]>([]);
  const [previewEnabled, setPreviewEnabled] = useState(false);
  const [previewData, setPreviewData] = useState<ArtResult | null>(null);
  const [loading, setLoading] = useState(false);

  function getBookmarkedArtByIds(): number[] {
    const stored = localStorage.getItem("bookmarkedArt");
    if (!stored) return [];
    try {
      const items = JSON.parse(stored);
      return items.map((item: { id: number }) => item.id);
    } catch (e) {
      console.error("Invalid bookmarks in localStorage");
      return [];
    }
  }

  // Debounced API call function
  const debouncedSearch = useCallback(
    debounce((searchTerm: string) => {
      if (!searchTerm.trim()) {
        setResults([]);
        return;
      }

      setLoading(true);

      // This would be best placed in an .env file but for the sake of the task, I'm leaving it here
      const apiKey = "2fb38059-3f24-4f47-a0e1-4f037c491b50";
      const apiUrl = "https://api.harvardartmuseums.org";
      const url = `${apiUrl}/object?apikey=${apiKey}&q=${searchTerm}`;

      fetch(url)
        .then((response) => response.json())
        .then((data) => {
          // gets the bookmarked art ids from localStorage
          const bookmarkedIds = getBookmarkedArtByIds();
          // along with the result data, add the bookmarked state to the result too
          setResults(
            data.records.map((result: ArtResult) => ({
              ...result,
              bookmarked: bookmarkedIds.includes(result.id),
            }))
          );
          setLoading(false);
        })
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
        {loading ? (
          <div className="spinner-container">
            <div className="spinner"></div>
          </div>
        ) : (
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
        )}
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
