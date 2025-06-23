export interface ArtResult {
  id: number;
  title: string;
  description: string;
  primaryimageurl: string;
  people: {
    name: string;
  }[];
  datebegin: string;
  url: string;
}
