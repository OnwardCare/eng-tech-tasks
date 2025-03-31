import axios, { AxiosRequestConfig, AxiosPromise } from 'axios';

interface IFootballTeam {
  estimated_value_numeric: number;
  name: string;
  number_of_league_titles_won: number;
}

interface IGetFootballTeamsResponse {
  status: string;
  data: {
      data: IFootballTeam[];
      page: number;
      total_pages: number;
  }
}

const sortFootballTeams = (footballTeams: IFootballTeam[]): IFootballTeam[] => {

  
  const sortedFootballTeams = footballTeams.sort((a, b) => {
      if (a.estimated_value_numeric !== b.estimated_value_numeric) {
          return b.estimated_value_numeric - a.estimated_value_numeric;
      }
      
      return a.name.localeCompare(b.name)
  });
  
  return sortedFootballTeams;
}

const getAllFootballTeams = async (nation: string) => {
  const allFootballTeams = [] as IFootballTeam[];
  
  const recursiveGetFootballTeams = async (page: number) => {
      const footballTeamsResponse: IGetFootballTeamsResponse =
          await axios.get(`https://jsonmock.hackerrank.com/api/football_teams?nation=${nation}&page=${page}`);
          
      const footballTeamsData = footballTeamsResponse.data;
      const footballTeams = footballTeamsData.data;
      
      allFootballTeams.push(...footballTeams);
      
      if (footballTeamsData.page < footballTeamsData.total_pages) {
          await recursiveGetFootballTeams(page + 1);
      }
  }
  
  await recursiveGetFootballTeams(1);
  
  return allFootballTeams;
}

async function eliteClubs(nation: string, minValuation: number, minTitlesWon: number): Promise<string[] | null>  {
  try {
      const allFootballTeams = await getAllFootballTeams(nation);
      
      const filteredFootballTeams =
          allFootballTeams
              .filter(footballTeam => {
                  const {estimated_value_numeric, number_of_league_titles_won} = footballTeam;
                  
                  return estimated_value_numeric >= minValuation && number_of_league_titles_won >= minTitlesWon
              });
      
      const sortedFootballTeams = sortFootballTeams(filteredFootballTeams);
      
      const footballTeamsNames = sortedFootballTeams.map(footballTeam => footballTeam.name);

      return footballTeamsNames;
  } catch (error) {
      return null;
  }
}

export default eliteClubs;