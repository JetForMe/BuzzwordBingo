//
//  api.js
//  bingo
//
//  Created by Rick Mann on 2025-08-01.
//


let gPlayerID = null

export default
{
	setPlayerID(inPlayerID)
	{
		gPlayerID = inPlayerID
	},
	
	async login(inUsername)
	{
		const response = await fetch(`/api/players/${encodeURIComponent(inUsername)}`,
		{
			method: "PUT",
			headers:
			{
				"Content-Type": "application/json"
			},
			body: JSON.stringify(
			{
				name: inUsername
			})
		})

		if (!response.ok)
		{
			throw new Error(`Server returned ${response.status}`)
		}

		const player = await response.json()
		return player
	},
	
	async getPlayerCard(inGameID)
	{
		const response = await fetch(`/api/games/${encodeURIComponent(inGameID)}/card`,
		{
			method: "GET",
			headers:
			{
				"Content-Type": "application/json",
				"Player-ID" : gPlayerID
			}
		})

		if (!response.ok)
		{
			throw new Error(`Error fetching PlayerCard: ${response.status}`)
		}

		const card = await response.json()
		return card
	}
}
