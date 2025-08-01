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
	
	async getPlayerCard(gameID)
	{
	}
}
