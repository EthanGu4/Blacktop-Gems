## Blacktop Gems

A simple full-stack NBA analytics app for identifying active players and surfacing potential hidden gems, built with Ruby on Rails, PostgreSQL hosted on AWS RDS, and nba api by swar on github (credit: https://github.com/swar/nba_api)

## Tech Stack

* Frontend: Hotwire (Turbo + Stimulus)

* Backend: Ruby on Rails

* Database: PostgreSQL (AWS RDS)

* External API: NBA API (read-only)

## Features

* General browser for players with working search query

* Tab for finding top players as well as "hidden gems"

* Customized algorithm named HotHand used to determine GEM score of players

## Setup

Visit: https://blacktop-gems.onrender.com/

Or locally,

bundle install
create environment variables + link database

## Running the app

bin/rails s
or
rails s

## Preview

* Home
<img width="1919" height="992" alt="image" src="https://github.com/user-attachments/assets/0ae50207-f462-4af5-bae9-abc894de51cc" />
<br><br><br>

* Browse
<img width="1895" height="993" alt="image" src="https://github.com/user-attachments/assets/cf908f43-6248-4f07-98ee-8e5642b45863" />
<br><br><br>

* Customizable Gems Query
<img width="1894" height="994" alt="image" src="https://github.com/user-attachments/assets/9b78a5aa-907f-4ffe-9f60-010b22ea5d00" />
<br><br><br>

* Player Profile Card
<img width="1491" height="947" alt="image" src="https://github.com/user-attachments/assets/75b08daa-7b4c-4d37-8323-1560af0cdb89" />


## Next Steps
* Create script for daily updates to db

* More fleshed out styling and custom player cards

* More pages with increased use of the nba api

©Ethan Gu





