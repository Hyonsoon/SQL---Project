/*
Let's examine the data pertaining to the Covid-19 pandemic
in Canada and other countries around the world.
*/

--Analyze all available data on Covid-19 for all countries worldwide.
SELECT *
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location,date;

--Analyze all available data on Covid-19 specifically for Canada.
SELECT *
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
	AND location LIKE '%Canada%'
ORDER BY location,date;

--Analyzing location, date, cases, deaths, and population data
--for all regions in Canada and other countries for COVID-19.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
Where continent IS NOT NULL
ORDER BY location, date;

--(Canada)
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
Where continent IS NOT NULL
	AND location LIKE '%Canada%'
ORDER BY location, date;



-- Comparing COVID-19 cases, deaths, and mortality rate in Canada and other countries.
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPct
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- (Canada)
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPct
FROM CovidProject..CovidDeaths
WHERE location LIKE '%Canada%'
	AND continent IS NOT NULL
ORDER BY location, date;




-- Comparing COVID-19 infection rate in Canada and other countries by comparing total cases to population.
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS InfectedPct
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- (Canada)
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS InfectedPct
FROM CovidProject..CovidDeaths
WHERE location LIKE '%Canada%'
	AND continent IS NOT NULL
ORDER BY location, date;




-- Top countries with highest COVID-19 infection rate per population.
SELECT location, population, MAX(total_cases) AS HighestInfected,
	   ROUND(Max((total_cases/population))*100,1) AS InfectedPct
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPct DESC;
-- Cyprus has the highest percentage of infected population
-- with 71.2% infected and a total of 638,062 infections.





--Top countries with highest COVID-19 death rate per population.
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeath,
	ROUND(Max((total_deaths/population))*100,2) AS DeathPct
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathPct DESC;
-- Peru has the highest COVID-19 death rate of 0.64% with a total of 218,530 deaths.




-- Continents with the highest COVID-19 death rate per population.
SELECT continent, SUM(CAST(new_deaths AS int)) AS TotalDeath
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath DESC;
--Europe has the highest number of total COVID-19 deaths with a count of 2,013,155





-- Global COVID-19 data including total cases, total deaths, and death percentage.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
	   ROUND(SUM(cast(new_deaths AS int))/SUM(new_cases)*100,2) AS DeathPct
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
-- Globally, there have been 665,487,930 reported cases of COVID-19,
-- with a death rate of 1% (6,687,082 reported deaths).

-- Canada's COVID-19 data including total cases, total deaths, and death percentage.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
	   ROUND(SUM(cast(new_deaths AS int))/SUM(new_cases)*100,2) AS DeathPct
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
	 AND location LIKE 'Canada'
-- In Canada, there have been 4,556,754 reported cases of COVID-19,
-- with a death percentage of 1.11% (50,374 reported deaths).



-- Compare total population to vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(bigint,v.new_vaccinations))
	OVER (PARTITION BY d.location ORDER BY d.location, d.Date) AS totalvac
FROM CovidProject..CovidDeaths AS d
INNER Join CovidProject..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.continent, d.location, d.date;

-- Compare total population to vaccinations (Canada)
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(bigint,v.new_vaccinations))
	OVER (PARTITION BY d.location ORDER BY d.location, d.Date) AS totalvac
FROM CovidProject..CovidDeaths AS d
INNER Join CovidProject..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
	AND d.location LIKE '%Canada%'
ORDER BY d.continent, d.location, d.date;






-- Use CTE and Partition By to calculate the highest COVID-19 vaccination percentage
WITH popvac AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(bigint,v.new_vaccinations))
	OVER (PARTITION BY d.location ORDER BY d.location, d.Date) AS totalvac
FROM CovidProject..CovidDeaths AS d
INNER Join CovidProject..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
)
Select *,
	ROUND((totalvac/Population)*100,2) AS vacpct
From popvac
ORDER BY vacpct DESC, popvac.continent, popvac.location, popvac.date;
-- Cuba has the highest COVID-19 vaccination percentage at 326.7%,
-- indicating that many individuals have received at least 3 doses.

-- (Canada)
WITH popvac AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CONVERT(bigint,v.new_vaccinations))
	OVER (PARTITION BY d.location ORDER BY d.location, d.Date) AS totalvac
FROM CovidProject..CovidDeaths AS d
INNER Join CovidProject..CovidVaccinations AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
	AND d.location = 'Canada'
)
Select *,
	ROUND((totalvac/Population)*100,2) AS vacpct
From popvac
ORDER BY vacpct DESC, popvac.continent, popvac.location, popvac.date;
-- Canada has the COVID-19 vaccination percentage at 250.37%!
