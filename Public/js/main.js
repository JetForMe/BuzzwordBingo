import api from "./api.js"

document.addEventListener("DOMContentLoaded", () =>
{
	(async () =>
	{
		const playerID = localStorage.getItem("playerID")
		api.setPlayerID(playerID)
		
		loadCurrentGame()
		
		await updateUI()
		await showDefaultView()
		
		//	The Games button…
		
		const gamesLink = document.getElementById("games-link")
		gamesLink.onclick = (e) =>
		{
			e.preventDefault()
			showView("games-view")
		}
		
		//	The login submit button…
		
		const loginSubmit = document.getElementById("login-submit")
		loginSubmit.onclick = (e) =>
		{
			e.preventDefault()
			login()
		}
		
		//	Temp card button…
		
		const cardLink = document.getElementById("card-link")
		cardLink.onclick = (e) =>
		{
			e.preventDefault()
			showView("card-view")
		}
		
	})()
})

async function showView(viewId)
{
	const current = document.querySelector(".view.active")
	const next = document.getElementById(viewId)

	if (current === next)
	{
		return
	}

	if (current)
	{
		if (current.id == "card-view" && gWebsocket)
		{
			const ws = gWebsocket
			gWebsocket = null
			ws.close()
		}
		
		current.style.opacity = 0
		await updateView(viewId)
		setTimeout(() =>
		{
			current.classList.remove("active")
			next.classList.add("active")
			requestAnimationFrame(() => next.style.opacity = 1)
		}, 200) // matches transition duration
	}
	else
	{
		next.classList.add("active")
		requestAnimationFrame(() => next.style.opacity = 1)
	}
}

async function updateView(inViewID)
{
	console.log("Updating view " + inViewID)
	if (inViewID == "games-view")
	{
		try
		{
			const response = await fetch(`/api/games`,
			{
				method: "GET",
				headers:
				{
					"Accept": "application/json"
				}
			})

			if (!response.ok)
			{
				throw new Error(`Server returned ${response.status}`)
			}

			const games = await response.json()
			console.log("Games: " + JSON.stringify(games))
			renderGamesList(games)
		}
		
		catch (err)
		{
			console.error("get games failed:", err)
			alert("get games failed. Please try again.")
		}
	}
}

async function login()
{
	const input = document.getElementById("username")
	const username = input.value.trim()

	if (!username || username.length < 3)
	{
		alert("Please enter a name at least three characters long.")
		return
	}

	try
	{
		const player = await api.login(username)
		
		// Store player ID (or whatever else you need)…
		
		localStorage.setItem("playerID", player.id)
		api.setPlayerID(player.id)
		
		// Optionally store the name too
		localStorage.setItem("playerName", player.name)

		// Move to game list view or whatever's next
		await updateUI()
		await showDefaultView()
	}
	
	catch (err)
	{
		console.error("Login failed:", err)
		alert("Login failed. Please try again.")
	}
}

async function
updateUI()
{
	const playerID = localStorage.getItem("playerID")
	const playerName = localStorage.getItem("playerName")

	//	Show the player name (if any)…
	
	const playerNameElement = document.getElementById("player-name")
	if (playerName)
	{
		playerNameElement.textContent = playerName
	}
	else
	{
		playerNameElement.textContent = null
	}
	
	//	If there’s a game, set it on the card view…
	
	const game = JSON.parse(localStorage.getItem("currentGame"))
	if (game)
	{
		const gn = document.getElementById("gameName")
		gn.textContent = game.displayName
	}
	
	//	Set up the Login/Logout button…
	
	const authLink = document.getElementById("auth-link")
	if (playerID)
	{
		authLink.textContent = "Logout"
		authLink.onclick = (e) =>
		{
			e.preventDefault()
			localStorage.removeItem("playerID")
			localStorage.removeItem("playerName")
			localStorage.removeItem("playerCard")
			localStorage.removeItem("currentGame")
			localStorage.removeItem("currentGameID")
			location.reload()
		}
	}
	else
	{
		authLink.textContent = "Login"
		authLink.onclick = (e) =>
		{
			e.preventDefault()
			showView("login-view")
		}
	}
}

/**
	Shows the most appropriate view given the
	current state. Generally call this after calling `updateUI`
	in response to some action.
*/

async function
showDefaultView()
{
	
	//	Show the appropriate view:
	//
	//	login-view if no user logged in
	//	card-view if logged in and a game is in progress
	//	games-view if logged in and no game in progress
	
	const playerID = localStorage.getItem("playerID")
	const storedCard = localStorage.getItem("playerCard")
	const card =  storedCard ? JSON.parse(storedCard) : null
	
	if (!playerID)
	{
		showView("login-view")
	}
	else if (card)
	{
		renderCard(card)
		showView("card-view")
	}
	else
	{
		showView("games-view")
	}
}

async function
joinGame(inGameID)
{
	localStorage.setItem("currentGameID", inGameID)
	await loadCurrentGame()
	await updateUI()
}

let	gWebsocket = null

async function
loadCurrentGame()
{
	const gameID = localStorage.getItem("currentGameID")
	if (!gameID)
	{
		return
	}
	
	const game = await api.getGame(gameID)
	localStorage.setItem("currentGame", JSON.stringify(game))
	
	const card = await api.getPlayerCard(gameID)
	localStorage.setItem("playerCard", JSON.stringify(card))
	renderCard(card)
	showView("card-view")
	
	//	Connect to the card’s websocket…
	
	openWebsocket(card.id)
}

function
openWebsocket(inCardID)
{
	//	Close any existing websocket…
	
	if (gWebsocket)
	{
		const ws = gWebsocket
		gWebsocket = null
		ws.close()
	}
	
	//	Open the new one…
	
	const proto = location.protocol === "https:" ? "wss" : "ws"
	gWebsocket = new WebSocket(`${proto}://${location.host}/api/cards/${inCardID}`)
	gWebsocket.addEventListener("open",
		(inEvent) =>
		{
			console.log("websocket opened")
		})
	
	gWebsocket.addEventListener("close",
		(inEvent) =>
		{
			console.log("websocket closed", JSON.stringify(inEvent))
			console.log("gWebsocket: ", gWebsocket ? "yes" : "null")
			
			//	If there’s still a websocket, it wasn't intentionally
			//	closed, so reconnect…
			
			if (gWebsocket)
			{
				setTimeout(() => { openWebsocket(inCardID) }, 1000)
			}
		})
	
	gWebsocket.addEventListener("error",
		(inEvent) =>
		{
			console.log("websocket error: ", JSON.stringify(inEvent))
		})
	
	gWebsocket.addEventListener("message",
		(inEvent) =>
		{
			console.log("websocket message received: ", inEvent.data)
			
			let event = JSON.parse(inEvent.data)
			if (event.cardID != inCardID)
			{
				console.log(`Event for another card: ${event.cardID}; our card: ${inCardID}`)		//	TODO: Do we want everyone to get this event?
				return
			}
			
			const cardsElem = document.getElementById("cards")
			const cardCell = cardsElem.querySelector(`[data-sequence="${event.sequence}"]`)
			cardCell.dataset.marked = event.marked
		})
}


//	MARK: - • Rendering HTML -

function
renderGamesList(games)
{
	const container = document.getElementById("games-list")
	container.innerHTML = ""		//	Clear existing contents

	if (games.length === 0)
	{
		container.textContent = "No games available."
		return
	}

	games.forEach(game =>
	{
		//	Create the accordion…
		
		const details = document.createElement("details")
		details.setAttribute("name", "game")
		
		//	Add the summary…
		
		const summary = document.createElement("summary")
		
		const span = document.createElement("span")
		span.className = "label"
		span.textContent = game.name
		summary.appendChild(span)
		
		const button = document.createElement("button")
		button.className = "join-btn"
		button.textContent = "Join"
		button.onclick = () => joinGame(game.id)
		summary.appendChild(button)
		
		details.appendChild(summary)
		
		//	Add the word list as a comma-separated paragraph…
		
		const words = document.createElement("p")
		words.className = "wordList"
		details.appendChild(words)
		words.textContent = game.words.map(w => w.word).sort().join(", ")
		
		container.appendChild(details)
	})
}

function
renderCard(inCard)
{
	const container = document.getElementById("cards")
	container.innerHTML = ""		//	Clear existing contents
	
	const card = document.createElement("div")
	card.className = "bingo-card"
	container.appendChild(card)
	
	inCard.words.forEach(word =>
	{
		//	Create the cell…
		
		const cell = document.createElement("div")
		card.appendChild(cell)
		cell.dataset.sequence = word.sequence
		if (word.marked)
		{
			cell.dataset.marked = word.marked
		}
		
		//	Add the checkmark…
		
		//cell.insertAdjacentHTML("afterbegin", `<span>✔︎</span>`);
		
		//	Add the actual word text…
		
		const cellContent = document.createElement("div")
		cell.appendChild(cellContent)
		cellContent.textContent = word.word
	})
	
	//	Shrink to fit after the browser has laid things out…
	
//	requestAnimationFrame(() =>
//	{
//		document.querySelectorAll('.bingo-card > div').forEach(shrinkToFitCard);
//	})
	
	//	Add tap handler to each cell…
	
	document.querySelectorAll(".bingo-card > div").forEach(cell =>
	{
		cell.addEventListener("click", async (inEvent) =>
		{
			const sequence = cell.dataset.sequence
			console.log("Cell clicked:", sequence, ", marked before: ", cell.dataset.marked)
			let newMark = true
			if (cell.dataset.marked == "true")
			{
				newMark = false
			}
			const cw = await api.markCard(inCard.id, sequence, newMark)
		})
	})
}

function shrinkToFitCard(container, minFontSize = 8, step = 0.5) {
	const content = container.firstElementChild;
	if (!content) return;

	// Let wrapping happen
	content.style.whiteSpace = 'normal';
	content.style.wordBreak = 'break-word';

	// Start large, reduce if needed
	let fontSize = 20;
	content.style.fontSize = `${fontSize}px`;

	// Measure container box — this is the limit
	const maxHeight = container.offsetHeight;
	const maxWidth = container.offsetWidth;

	// Measure content — this must stay within the box
	let scrollH = content.scrollHeight;
	let scrollW = content.scrollWidth;

	while ((scrollH > maxHeight || scrollW > maxWidth) && fontSize > minFontSize) {
		fontSize -= step;
		content.style.fontSize = `${fontSize}px`;

		scrollH = content.scrollHeight;
		scrollW = content.scrollWidth;
	}
}
