import axios, { AxiosRequestConfig, AxiosPromise } from 'axios';

interface team  {
  name: string,
  captain: string,
  vice_captain: string,
  goalkeeper: string,
  number_of_players: number,
  current_active_players: number,
  league:string,
  nation: string,
  estimated_value: string,
  estimated_value_numeric: number,
  number_of_league_titles_won: number,
  last_league_title_winning_year: number,
  number_of_champions_league_won: number,
  last_champions_league_winning_year: null,
  total_silverware_count: number,
  manager: string,
  stadium_name: string,
  stadium_capacity: number,
  league_position_2021: number,
  league_top_three_finishes: number,
  highest_goalscorer: string,
  highest_assist_provider: string,
  highest_clean_sheet_holder: string,
  most_capped_player: string,
  appearances_most_capped_player: number
  number_of_runner_ups_in_champions_league: number,
}

async function eliteClubs(nation: string, minValuation: number, minTitlesWon: number): Promise<string[]> {
  try{
      const url = `https://jsonmock.hackerrank.com/api/football_teams?nation=${encodeURIComponent(nation)}`
      let allTeams : team[] = []
      let page = 1
      let totalPages = 2
      
      while(page<=totalPages){
          const response = await axios.get(`${url}&page=${page}`)
          if(response.data && response.data.data){
              allTeams.push(...response.data.data)
              totalPages= response.data.total_pages
          }
          page++
      }
      
      return allTeams.filter((team: team)=>team.estimated_value_numeric >= minValuation && team.total_silverware_count >= minTitlesWon)
      .sort((a:team,b:team)=>{
          if(b.estimated_value_numeric !== a.estimated_value_numeric){
              return b.estimated_value_numeric - a.estimated_value_numeric
          }
          return a.name.localeCompare(b.name)
      })
      .map((team:team)=>team.name)
  }catch (err){
      console.log(err)
      throw Error (err)    
  }
}

export default eliteClubs;