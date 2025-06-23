import "./ArtItem.css";
import { ArtResult } from "../../types/types";
import { SetStateAction, Dispatch, useState } from "react";

const ArtItem = ({
  result,
  setEnabled,
  setPreviewData,
}: {
  result: ArtResult;
  setEnabled: Dispatch<SetStateAction<boolean>>;
  setPreviewData: Dispatch<SetStateAction<ArtResult | null>>;
}) => {
  const [bookmarked, setBookmarked] = useState(result.bookmarked || false);

  const toggleBookmark = (item: ArtResult) => {
    const key = "bookmarkedArt";
    const existing = localStorage.getItem(key);
    // toggle the bookmarked state
    setBookmarked((prev) => !prev);
    let bookmarks: ArtResult[] = existing ? JSON.parse(existing) : [];

    if (bookmarks.some((bookmark) => bookmark.id === item.id)) {
      // remove item from bookmarks if it exists
      bookmarks = bookmarks.filter((bookmark) => bookmark.id !== item.id);
    } else {
      // add item to bookmarks if it doesn't exist
      bookmarks.push(item);
    }

    localStorage.setItem(key, JSON.stringify(bookmarks));
  };

  return (
    <>
      <div className="art-item">
        <div className="art-bookmark">
          <button
            className="bookmark-button"
            aria-label="Bookmark"
            onClick={() => {
              toggleBookmark(result);
            }}
          >
            {bookmarked ? (
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                fill="currentColor"
                viewBox="0 0 24 24"
              >
                <path d="M6 4c-1.1 0-2 .9-2 2v16l8-3.2 8 3.2V6c0-1.1-.9-2-2-2H6z" />
              </svg>
            ) : (
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z" />
              </svg>
            )}
          </button>
        </div>
        <a href={result.url} target="_blank" rel="noopener noreferrer">
          {result.primaryimageurl && (
            <img src={result.primaryimageurl} alt={result.title} />
          )}
          <div className="art-item-content">
            <h2>{result.title}</h2>
            {result.people && result.people.length > 0 && (
              <p>{result.people[0].name}</p>
            )}
            <p>{result.dated}</p>
          </div>
        </a>
        <button
          type="button"
          className="generic-button"
          onClick={() => {
            setEnabled(true);
            setPreviewData(result);
          }}
        >
          Preview
        </button>
      </div>
    </>
  );
};

export default ArtItem;
