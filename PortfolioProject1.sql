SELECT *
FROM..CovidDeaths$
WHERE continent is NOT NULL
ORDER BY 3, 4;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM..CovidDeaths$
ORDER BY 1,2;

--Total cases vs Total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM..CovidDeaths$
ORDER BY 1,2;

--Shows likelihood of of dying if you contract covid in the US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2;

--looking at population vs total_cases
--shows infection rate
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infection_rate
FROM..CovidDeaths$
--WHERE location LIKE '%states%'
ORDER by 1,2;

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count,
MAX(total_cases/population)*100 AS highest_infection_rate
FROM..CovidDeaths$
GROUP BY location, population
ORDER BY highest_infection_rate DESC;

--Showing highest death rate per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

--Death rate broken down by Continent
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;

SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

--Global Numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100
AS global_death_rate
FROM..dbo.CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Looking at total populations vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM..CovidDeaths$ dea
JOIN..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vax
FROM..CovidDeaths$ dea
JOIN..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--USE CTE
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_count_vax)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vax
FROM..CovidDeaths$ dea
JOIN..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_count_vax/population)*100
FROM pop_vs_vac;

--creating a view to store data for later visualizations
CREATE VIEW percent_pop_vax AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count_vax
FROM..CovidDeaths$ dea
JOIN..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL