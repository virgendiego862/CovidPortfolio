SELECT *
  FROM `academic-aloe-381420.portafolio.CovidDealth`
  where continent is not null
  order by 3,4

 LIMIT 1000;

 SELECT *  
   FROM `academic-aloe-381420.portafolio.CovidVaccination`
   order by 3,4 
 
 LIMIT 1000;

--select data thar we are goin to using

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM `academic-aloe-381420.portafolio.CovidDealth`
where continent is not null
order by 1,2;

--Total case VS Total Dealths

Select 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases) as DeathPercentage
FROM `academic-aloe-381420.portafolio.CovidDealth`
where continent is not null
order by 1;


--Total case VS Total Dealths US

Select 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases) as DeathPercentage
FROM `academic-aloe-381420.portafolio.CovidDealth`
  --where location like '%States%' and 
  where continent is not null
order by 1,2;


-- Total Dealths  VS Population US

Select 

    location,
    date,
    total_cases,
    population,
    (total_cases/population) as CasesPercentage
FROM `academic-aloe-381420.portafolio.CovidDealth`
  where location like '%States%' and  continent is not null
order by 1,2;


--Countries whit highest infection ride compare to population

Select 
    location,
    population, 
    MAX(total_cases) as HighestInfectionCount,
    MAX(total_cases/population) * 100 as CasesPercentage
FROM `academic-aloe-381420.portafolio.CovidDealth`
where continent is not null
group by location,population
order by HighestInfectionCount DESC;


Select 
    location,
    SUM(new_deaths ) as DeathCount
FROM `academic-aloe-381420.portafolio.CovidDealth`
where continent is  null and location not in
 ('World','European Union','International','Lower middle income','Low income','High income','Upper middle income')
group by location
order by DeathCount DESC;

--Countries whit highest death count per population

Select 
    location,
    MAX(total_deaths ) as DeathCount
FROM `academic-aloe-381420.portafolio.CovidDealth`
where continent is not null
group by location
order by DeathCount DESC;



--continents with the highest number of deaths
Select 
    continent,
    MAX(total_deaths) as DeathCount
FROM `academic-aloe-381420.portafolio.CovidDealth`

where continent is not null
group by continent
order by DeathCount DESC;


Select 
    location,
    MAX(total_deaths) as DeathCount
FROM `academic-aloe-381420.portafolio.CovidDealth`

where continent is null
group by location
order by DeathCount DESC;


--global numbers
  --- total per date
Select 
    date,
    SUM(new_cases) as total_cases,
    sum(new_deaths) as total_deaths,
    sum(new_deaths)/ nullif (sum(new_cases),0) *100  as DeathPercentage
FROM `academic-aloe-381420.portafolio.CovidDealth`
where continent is not null
group by date
order by 1;

--- total

Select 
   
    SUM(new_cases) as total_cases,
    sum(new_deaths) as total_deaths,
    sum(new_deaths)/ nullif (sum(new_cases),0) *100  as DeathPercentage
FROM `academic-aloe-381420.portafolio.CovidDealth`
where continent is not null

order by 1;


-- join two tables Dealth and Vaccination

SELECT *
FROM `academic-aloe-381420.portafolio.CovidDealth`  dea
JOIN   `academic-aloe-381420.portafolio.CovidVaccination` vac
ON  dea.location= vac.location AND dea.date= vac.date;


--looking at Total Population vs Vaccination

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population, 
    vac.new_vaccinations


FROM `academic-aloe-381420.portafolio.CovidDealth`  dea
JOIN   `academic-aloe-381420.portafolio.CovidVaccination` vac
ON  dea.location= vac.location AND dea.date= vac.date
where dea.continent is not null
ORDER BY 1,2,3;


--looking at Total Population vs Vaccination
-- per location
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeapleVaccinated


FROM `academic-aloe-381420.portafolio.CovidDealth`  dea
JOIN   `academic-aloe-381420.portafolio.CovidVaccination` vac
ON  dea.location= vac.location AND dea.date= vac.date
where dea.continent is not null
ORDER BY 2,3;


--use cte


SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population, 
    vac.new_vaccinations


FROM `academic-aloe-381420.portafolio.CovidDealth`  dea
JOIN   `academic-aloe-381420.portafolio.CovidVaccination` vac
ON  dea.location= vac.location AND dea.date= vac.date
where dea.continent is not null
ORDER BY 1,2,3;


--looking at Total Population vs Vaccination
-- per location
 
with PopVsVac
as (
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeapleVaccinated
   -- (RollingPeapleVaccinated/dea.population) * 100 as average


FROM `academic-aloe-381420.portafolio.CovidDealth`  dea
JOIN   `academic-aloe-381420.portafolio.CovidVaccination` vac
ON  dea.location= vac.location AND dea.date= vac.date
where dea.continent is not null
)
Select * from PopVsVac;

-- temp table

 DROP Table if exists `academic-aloe-381420.portafolio.PercentPopulationVaccinated`;
Create Table `academic-aloe-381420.portafolio.PercentPopulationVaccinated`
(
    continent string(255),
    location string(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    RollingPeapleVaccinated numeric
);

INSERT INTO `academic-aloe-381420.portafolio.PercentPopulationVaccinated`

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeapleVaccinated
   


FROM `academic-aloe-381420.portafolio.CovidDealth`  dea
JOIN   `academic-aloe-381420.portafolio.CovidVaccination` vac
ON  dea.location= vac.location AND dea.date= vac.date;
--where dea.continent is not null

Select * , (RollingPeapleVaccinated/population) * 100 as average
 from `academic-aloe-381420.portafolio.PercentPopulationVaccinated`;


 -- create view percentage of population vaccinated

 CREATE VIEW `academic-aloe-381420.portafolio.PercentPopulationVaccinated1`
 as 

 
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeapleVaccinated
   


FROM `academic-aloe-381420.portafolio.CovidDealth`  dea
JOIN   `academic-aloe-381420.portafolio.CovidVaccination` vac
ON  dea.location= vac.location AND dea.date= vac.date;




select * from  `academic-aloe-381420.portafolio.PercentPopulationVaccinated1`;
