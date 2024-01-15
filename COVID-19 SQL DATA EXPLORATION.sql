
--Showing the Covid-19 Death Table

SELECT *
FROM dbo.CovidDeaths$
WHERE continent is not null 
ORDER BY 2,3,4;

-- Selecting Data to start with

SELECT continent, Location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths$
WHERE continent is not null 
ORDER BY 1,2,3;

-- Total Cases vs Total Deaths
-- What is the likelyhood of dying if one contact Covid-19 in Nigeria?
SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths$
WHERE location = 'Nigeria'
and continent is not null 
ORDER BY 1,2;

-- Total Cases vs Population
-- What is the chance of being diagnosed with Covid-19

SELECT Location, date, Population, total_cases,  (total_cases/population)*1000000 as Part_Per_Million_Infected
FROM dbo.CovidDeaths$
ORDER BY 1,2;


-- What countries has Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM dbo.CovidDeaths$
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC

-- What countries has the Highest Death Count per Population

SELECT Location, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM dbo.CovidDeaths$
WHERE continent is not null 
GROUP BY Location
ORDER BY Total_Death_Count DESC

-- CONTINENTAL BREAKDOWN

-- Which are the contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM dbo.CovidDeaths$
WHERE continent is not null 
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- WORLDWIDE INFECTION AND DEATH CASE SUMMARY

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS Death_Percentage
FROM dbo.CovidDeaths$
WHERE continent is not null 
ORDER BY 1,2

-- Total Population vs Population Vaccinated
-- The Percentage of Population that has recieved at least one Covid Vaccine

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.Location Order by CD.location, CD.Date) AS Total_People_Vaccinated
FROM dbo.CovidDeaths$ CD
JOIN dbo.CovidVaccinations$ CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent is not null 
ORDER BY 2,3;

-- Use of CTE to perform Calculation on Partition By in previous query

WITH PopvsVAC (Continent, Location, Date, Population, New_Vaccinations, Total_People_Vaccinated)
as
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.Location Order by CD.location, CD.Date) AS Total_People_Vaccinated
FROM dbo.CovidDeaths$ CD
JOIN dbo.CovidVaccinations$ CV
	ON CD.location = CV.location
	AND CD.date = CV.date
WHERE CD.continent is not null 
)
SELECT *, (Total_People_Vaccinated/Population)*100 AS Percentage_Population_Vaccinated
FROM PopvsVAC

-- Use of Temp Table to perform Calculation on Partition By in previous query

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
Total_People_Vaccinated NUMERIC
)

INSERT INTO #Percent_Population_Vaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.location, CD.Date) AS Total_People_Vaccinated
FROM dbo.CovidDeaths$ CD
Join dbo.CovidVaccinations$ CV
	ON CD.location = CV.location
	and CD.date = CV.date

SELECT *, (Total_People_Vaccinated/Population)*100 AS Percentage_Population_Vaccinated
FROM #Percent_Population_Vaccinated

-- To create View to store data for later visualizations

CREATE VIEW Percent_Population_Vaccinated AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
, SUM(CONVERT(INT,CV.new_vaccinations)) OVER (PARTITION BY CD.Location ORDER BY CD.location, CD.Date) AS Total_People_Vaccinated
FROM dbo.CovidDeaths$ CD
JOIN dbo.CovidVaccinations$ cv
	ON CD.location = CV.location
	and CD.date = CV.date
WHERE CD.continent is not null 