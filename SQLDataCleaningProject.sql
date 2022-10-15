

/* 
Cleaning the data in SQL Server

*/
select *
from MyPortFolioProject..NashvilleHousing

--Standardize data formate

select SaleDateConverted, CONVERT(DATE,SaleDate) 
from MyPortFolioProject.dbo.NashvilleHousing



update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)
---------------------------------------------------------------------------------

-- populate property address data

select OwnerAddress
from MyPortFolioProject.dbo.NashvilleHousing
where OwnerAddress is null

SELECT * 
FROM MyPortFolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID

-- Self Join 
SELECT * 
FROM MyPortFolioProject.dbo.NashvilleHousing a
JOIN MyPortFolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] = b.[UniqueID ]
WHERE a.OwnerAddress is null

SELECT a.ParcelID, a.OwnerAddress, b.ParcelID, b.OwnerAddress, ISNULL(a.OwnerAddress,b.OwnerAddress)
FROM MyPortFolioProject..NashvilleHousing a
JOIN MyPortFolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
Where a.OwnerAddress is null

UPDATE a
SET OwnerAddress = ISNULL(a.OwnerAddress,b.OwnerAddress)
FROM MyPortFolioProject..NashvilleHousing a
JOIN MyPortFolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
Where a.OwnerAddress is null
----------------------------------------------------------------------------

-- Breaking out Address into indivual column(Address, City, State)
SELECT 
PropertyAddress FROM MyPortFolioProject..NashvilleHousing

--rid of after the comma
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address 
FROM MyPortFolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 3)
from MyPortFolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,  CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT * 
FROM MyPortFolioProject..NashvilleHousing

SELECT OwnerAddress
FROM MyPortFolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM MyPortFolioProject..NashvilleHousing
WHERE OwnerAddress is not null

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM MyPortFolioProject..NashvilleHousing
WHERE OwnerAddress is not null

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM MyPortFolioProject..NashvilleHousing
where OwnerAddress is not null


--Change Y and N to Yes or No in "Sold as Vagant" field
SELECT Distinct (SoldAsVacant)
FROM MyPortFolioProject..NashvilleHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM MyPortFolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant
,CASE When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	end
FROM MyPortFolioProject..NashvilleHousing

USE MyPortFolioProject
update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END
---------------------------------------------------------------

	--remove duplicate
	--Write CTE
	
	WITH RowNumCTE AS (
	select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID
				) row_num
	FROM MyPortFolioProject..NashvilleHousing
	)
	select *
	FROM RowNumCTE
	where row_num > 1  
	ORDER BY PropertyAddress

---------------------------------------------------------------------------
	--delete unused column
	SELECT *
	from MyPortFolioProject..NashvilleHousing

	ALTER TABLE MyPortFolioProject.dbo.NashvilleHousing
	DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress

	ALTER TABLE MyPortFolioProject.dbo.NashvilleHousing
	DROP COLUMN SaleDate

	--using this convert date format
	--I split property address indivisual comumn
	-- I delete property Address using substring and charindex
	--change yes no using case statement
	-- Remove duplicate using CTE, windows function.
	-- Delete useless column
	
	-- 


