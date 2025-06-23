"use client";
import React, { ChangeEvent } from "react";
import { SearchInput } from "../SearchInput/SearchInput";

interface HeaderProps {
  searchPlaceholder?: string;
  onSearchChange: (e: ChangeEvent<HTMLInputElement>) => void;
  searchValue?: string;
}

const SearchHeader = ({
  onSearchChange,
  searchValue,
  searchPlaceholder,
}: HeaderProps) => {
  return (
    <>
      <div className="">
        <SearchInput
          className="search-container"
          onChange={onSearchChange}
          value={searchValue}
          placeholder={searchPlaceholder}
        />
      </div>
    </>
  );
};

SearchHeader.displayName = "SearchHeader";
export default SearchHeader;
