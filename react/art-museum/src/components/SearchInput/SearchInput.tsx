import React, { useState, ChangeEvent } from "react";
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
  const [inputValue, setInputValue] = useState(value);

  return (
    <div className={className}>
      <div className="">
        <form action="" role="search" className="">
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
        </form>
      </div>
    </div>
  );
};
