import React, { useState, ChangeEvent, useEffect } from "react";
import "./SearchInput.css";

interface SearchInputProps {
  onChange: (e: ChangeEvent<HTMLInputElement>) => void;
  className: string;
  value?: string;
  placeholder?: string;
}

export const SearchInput = ({
  onChange,
  className,
  value,
  placeholder,
  ...props
}: SearchInputProps) => {
  const [inputValue, setInputValue] = useState(value || "");

  // Update internal state when value prop changes
  useEffect(() => {
    setInputValue(value || "");
  }, [value]);

  return (
    <div className={className}>
      <div className="">
        <div className="">
          <input
            value={inputValue}
            type="search"
            {...props}
            onChange={(e) => {
              setInputValue(e.target.value);
              onChange(e);
            }}
            className=""
            placeholder={placeholder}
            autoComplete="off"
            autoCapitalize="off"
            spellCheck="false"
            autoCorrect="off"
          />
        </div>
      </div>
    </div>
  );
};
