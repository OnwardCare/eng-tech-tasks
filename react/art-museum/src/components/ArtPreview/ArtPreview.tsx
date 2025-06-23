import "./ArtPreview.css";
import { ArtResult } from "../../types/types";
import { Dispatch, SetStateAction } from "react";

interface PreviewProps {
  data: ArtResult | null;
  enabled: boolean;
  setEnabled: Dispatch<SetStateAction<boolean>>;
}

const ArtPreview = (props: PreviewProps) => {
  const onClose = () => {
    props.setEnabled(false);
  };

  return (
    <>
      {props.enabled && (
        <div className="art-preview-container">
          <div className="art-preview-content">
            <div className="art-preview-header">
              <button
                type="button"
                className="close-button"
                aria-label="Close"
                onClick={onClose}
              >
                Close
              </button>
            </div>
            <div className="art-preview">
              {props.data && (
                <>
                  <h2>{props.data.title}</h2>
                  {props.data.images &&
                    props.data.images.length > 0 &&
                    props.data.images[0].baseimageurl && (
                      <img
                        src={props.data.images[0].baseimageurl}
                        alt={props.data.title}
                      />
                    )}

                  <div className="art-preview-details">
                    <p>
                      <strong>Title:</strong> {props.data.title}
                    </p>
                    {props.data.description && (
                      <p>
                        <strong>Description:</strong> {props.data.description}
                      </p>
                    )}
                    {props.data.dimensions && (
                      <p>
                        <strong>Dimensions:</strong> {props.data.dimensions}
                      </p>
                    )}
                    <p>
                      <strong>Date:</strong> {props.data.dated}
                    </p>
                    <p>
                      <strong>Accession Year: </strong>
                      {props.data.accessionyear}
                    </p>
                    {props.data.classification && (
                      <p>
                        <strong>Classification: </strong>
                        {props.data.classification}
                      </p>
                    )}
                    {props.data.culture && (
                      <p>
                        <strong>Culture: </strong>
                        {props.data.culture}
                      </p>
                    )}
                    {props.data.medium && (
                      <p>
                        <strong>Medium:</strong> {props.data.medium}
                      </p>
                    )}
                    {props.data.classification && (
                      <p>
                        <strong>Classification:</strong>{" "}
                        {props.data.classification}
                      </p>
                    )}

                    {props.data.people && props.data.people.length > 0 && (
                      <>
                        <p>
                          <strong>People:</strong>
                        </p>
                        {props.data.people[0].role === "Author" && (
                          <p>Author: {props.data.people[0].displayname}</p>
                        )}
                        {props.data.people[0].role === "Artist" && (
                          <p>
                            Artist:
                            {props.data.people[0].displayname}
                          </p>
                        )}
                      </>
                    )}
                  </div>
                  <button
                    type="button"
                    className="generic-button"
                    onClick={() => window.open(props.data?.url, "_blank")}
                  >
                    View on museum page
                  </button>
                </>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default ArtPreview;
