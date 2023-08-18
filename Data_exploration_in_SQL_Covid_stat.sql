/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select * from Portfolio_Project.coviddeaths;
select * from Portfolio_Project.covidvac;


select continent, iso_code, location from Portfolio_Project.coviddeaths group by iso_code, continent, location;


select location, date, total_cases, new_cases, total_deaths, population from Portfolio_Project.coviddeaths where location like '%Ukraine%' order by 1,2;
select population, location from Portfolio_Project.coviddeaths where continent='Europe' group by location, population;


-- Total cases vs total deaths
-- It shows likelihood of dying if you contract covid in certain country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from Portfolio_Project.coviddeaths
where location='Slovakia';


-- Total cases vs total total deaths
-- Shows what % of population got Covid
select location, date, population, total_cases, (total_deaths/Population)*100 as percent_of_population_infected
from Portfolio_Project.coviddeaths
where location='Slovakia';


-- Looking at Countries with Highest Infection Rate compared to Population on certain continent
select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as percent_of_population_infected
from Portfolio_Project.coviddeaths
where continent='Europe'
group by location, population
order by percent_of_population_infected desc;


-- Showing Countries with Highest Death Count per Population on certain continent
select location, population, MAX(cast(total_deaths as SIGNED)) as Total_Deaths_Count, MAX((total_deaths/population))*100 as percent_of_population_dead
from Portfolio_Project.coviddeaths
where continent='Europe'
group by location, population
order by percent_of_population_dead desc;

-- Showing Total Death Count by continent
select continent, MAX(cast(total_deaths as SIGNED)) as Total_Deaths_Count
from Portfolio_Project.coviddeaths
where continent is not NULL
group by continent
order by Total_Deaths_Count desc;

-- Showing Total cases and total deaths per day
select date, SUM(cast(New_cases as SIGNED)) as TotalCasesPerDay, SUM(cast(New_deaths as SIGNED)) as TotalDeathsPerDay, SUM(cast(New_deaths as SIGNED))/SUM(cast(New_cases as SIGNED))*100 as DeathPercentage
from Portfolio_Project.coviddeaths
where continent is not NULL
group by date;


-- Creating View to store data for later visualizations
Create view Total_cases_and_deaths as
select continent, MAX(cast(total_deaths as SIGNED)) as Total_Deaths_Count
from Portfolio_Project.coviddeaths
where continent is not NULL
group by continent
order by Total_Deaths_Count desc;

select * from total_cases_and_deaths;


-- Total Population vs Vaccinations
-- Shows number of people that has recieved at least one Covid Vaccine
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(CONVERT(vac.new_vaccinations, signed)) OVER (Partition by death.Location order by death.location, death.Date) as RollingPeopleVaccinated
from Portfolio_Project.coviddeaths as death
join Portfolio_Project.covidvac as vac
	on death.location=vac.location
    and death.date=vac.date
where death.continent<>'';


-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
	SUM(CONVERT(vac.new_vaccinations, signed)) OVER (Partition by death.Location order by death.location, death.Date) as RollingPeopleVaccinated
from Portfolio_Project.coviddeaths as death
join Portfolio_Project.covidvac as vac
	on death.location=vac.location
    and death.date=vac.date
where death.continent<>''
and death.Continent like '%europe%'
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentageOfVacinated
from PopvsVac;





update Portfolio_Project.coviddeaths SET population = 80088 where location ='Andorra';


