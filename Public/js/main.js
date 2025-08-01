import api from "./api.js"

document.addEventListener("DOMContentLoaded", () =>
{
	(async () =>
	{
		await updateUI()
		await showDefaultView()
		
		//	The Games button…
		
		const gamesLink = document.getElementById("games-link");
		gamesLink.onclick = (e) =>
		{
			e.preventDefault();
			showView("games-view")
		};
		
		//	The login submit button…
		
		const loginSubmit = document.getElementById("login-submit");
		loginSubmit.onclick = (e) =>
		{
			e.preventDefault();
			login()
		};
		
		//	Temp card button…
		
		const cardLink = document.getElementById("card-link");
		cardLink.onclick = (e) =>
		{
			e.preventDefault();
			showView("card-view")
		};
		
	})();
});

async function showView(viewId)
{
	const current = document.querySelector(".view.active");
	const next = document.getElementById(viewId);

	if (current === next)
	{
		return;
	}

	if (current)
	{
		current.style.opacity = 0;
		await updateView(viewId)
		setTimeout(() =>
		{
			current.classList.remove("active");
			next.classList.add("active");
			requestAnimationFrame(() => next.style.opacity = 1);
		}, 200); // matches transition duration
	}
	else
	{
		next.classList.add("active");
		requestAnimationFrame(() => next.style.opacity = 1);
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
			});

			if (!response.ok)
			{
				throw new Error(`Server returned ${response.status}`);
			}

			const games = await response.json();
			console.log("Games: " + JSON.stringify(games))
			renderGamesList(games)
		}
		
		catch (err)
		{
			console.error("get games failed:", err);
			alert("get games failed. Please try again.");
		}
	}
}

async function login()
{
	const input = document.getElementById("username");
	const username = input.value.trim();

	if (!username || username.length < 3)
	{
		alert("Please enter a name at least three characters long.");
		return;
	}

	try
	{
		const player = await api.login(username)
		
		// Store player ID (or whatever else you need)
		localStorage.setItem("playerID", player.id);

		// Optionally store the name too
		localStorage.setItem("playerName", player.name);

		// Move to game list view or whatever's next
		await updateUI()
		await showDefaultView()
	}
	
	catch (err)
	{
		console.error("Login failed:", err);
		alert("Login failed. Please try again.");
	}
}

async function
updateUI()
{
	const playerID = localStorage.getItem("playerID");
	const playerName = localStorage.getItem("playerName");

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

	//	Set up the Login/Logout button…
	
	const authLink = document.getElementById("auth-link");
	if (playerID)
	{
		authLink.textContent = "Logout";
		authLink.onclick = (e) =>
		{
			e.preventDefault();
			localStorage.removeItem("playerID");
			localStorage.removeItem("playerName");
			location.reload();
		};
	}
	else
	{
		authLink.textContent = "Login";
		authLink.onclick = (e) =>
		{
			e.preventDefault();
			showView("login-view")
		};
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
	
	const playerID = localStorage.getItem("playerID");
	if (!playerID)
	{
		showView("login-view")
	}
	else
	{
		showView("games-view")
	}
}


function
renderGamesList(games)
{
	const container = document.getElementById("games-list");
	container.innerHTML = ""		//	Clear existing contents

	if (games.length === 0)
	{
		container.textContent = "No games available."
		return
	}

	games.forEach(game =>
	{
		const details = document.createElement("details")
		details.setAttribute("name", "game")
		
		const summary = document.createElement("summary")
		
		const span = document.createElement("span")
		span.className = "label"
		span.textContent = game.name
		summary.appendChild(span)
		
		const button = document.createElement("button")
		button.className = "join-btn"
		button.textContent = "Join"
		button.onclick = () => joinGame(game.id);
		summary.appendChild(button)
		
		details.appendChild(summary)
		
		container.appendChild(details)
	});
}
