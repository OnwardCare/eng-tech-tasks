import "./ArtItem.css";
import { ArtResult } from "../../types/types";
import { SetStateAction, Dispatch } from "react";

const ArtItem = ({
  result,
  setEnabled,
}: {
  result: ArtResult;
  setEnabled: Dispatch<SetStateAction<boolean>>;
}) => {
  return (
    <>
      <div className="art-item">
        <a href={result.url} target="_blank" rel="noopener noreferrer">
          {result.primaryimageurl && (
            <img src={result.primaryimageurl} alt={result.title} />
          )}
          <div className="art-item-content">
            <h2>{result.title}</h2>
            {result.people && result.people.length > 0 && (
              <p>{result.people[0].name}</p>
            )}
            <p>{result.datebegin}</p>
          </div>
        </a>
        <button
          type="button"
          className="generic-button"
          onClick={() => setEnabled(true)}
        >
          Preview
        </button>
      </div>
    </>
  );
};

export default ArtItem;
