import "./ArtPreview.css";
import { ArtResult } from "../../types/types";
import { Dispatch, SetStateAction } from "react";

interface PreviewProps {
  // Confirmation parameters
  data?: ArtResult;
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
            <div className="art-preview">content here</div>
          </div>
        </div>
      )}
    </>
  );
};

export default ArtPreview;
