export interface ArtResult {
  id: number;
  title: string;
  description: string;
  primaryimageurl: string;
  people: {
    name: string;
    displayname: string;
    role: string;
    prefix: string;
  }[];
  datebegin?: string;
  dated?: string;
  url: string;
  images: {
    baseimageurl?: string;
  }[];
  medium: string;
  culture: string;
  dimensions: string;
  classification: string;
  accessionyear: string;
  bookmarked?: boolean;
}
