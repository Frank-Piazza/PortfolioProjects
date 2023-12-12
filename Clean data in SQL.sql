/* Clean data in SQL Queries*/

select * from PortfolioProject1.dbo.NashvilleHousing

/* Standardize date format*/

select SaleDate, CONVERT(date, SaleDate) 
from PortfolioProject1.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate);

ALTER TABLE NashvilleHousing /* UPDATE did not work! */
Add SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);


/* Populate Property Address Data*/
	/* Where PropertyAddress is NULL, populate with OwnerAddress ? */
SELECT * 
FROM PortfolioProject1.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;


 SELECT 
 PropertyAddress AS Address
 FROM PortfolioProject1.dbo.NashvilleHousing;

/* Break out address into individual columns (Address, City, State) */
/* LOCATE function in MySql equivalent to CHARINDEX in SSMS*/
 SELECT 
 SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1 /*get rid of comma by going back 1 position*/) AS Address,
  SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
  --CHARINDEX(',', PropertyAddress)
 FROM PortfolioProject1.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitAddress = 
							SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) - 1 );  -- Taken from above

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET PropertySplitCity = 
							SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)); -- Taken from above


SELECT * FROM PortfolioProject1.dbo.NashvilleHousing /*Look at 2  new columns at end with new data*/


/* Using PARSENAME instead of SUBSTRING (PS No PARSENAME in MySQL, use SUBSTRING_INDEX instead)*/
SELECT OwnerAddress, 
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)), /*PARSENAME by default looks for periods, so also use REPLACE with commas. PS works backwards */
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)),
	TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1))
FROM PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitAddress = 
							TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)); -- Taken from above

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitCity = 
							TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)); -- Taken from above

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE PortfolioProject1.dbo.NashvilleHousing
SET OwnerSplitState = 
							TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)); -- Taken from above

-- Check results
SELECT * FROM PortfolioProject1.dbo.NashvilleHousing /* All columns and data added to end far right*/



/* Change Y and N to Yes and No in "Sold as Vacant"*/
SELECT DISTINCT SoldAsVacant
FROM PortfolioProject1.dbo.NashvilleHousing 


SELECT  SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject1.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2

UPDATE PortfolioProject1.dbo.NashvilleHousing
	SET SoldAsVacant = 'Yes' WHERE SoldAsVacant = 'Y'

UPDATE PortfolioProject1.dbo.NashvilleHousing
	SET SoldAsVacant = 'No' WHERE SoldAsVacant = 'N' /* Could have used 1 CASE statement for Yes and No*/


/* Remove Duplicates (Generally not good practice to delete data from a database )*/
WITH RowNumCTE  AS  -- CTE - Common Table Expression, created in memory, acts like a sub query
(
SELECT *, ROW_NUMBER() OVER(
							PARTITION BY ParcelID,			-- FIND DUPLICATES.  Dont need to have PARTITION BY in Window OVER clause
										 PropertyAddress,		-- PARTITION BY (does not reduce no. rows returned) as opposed to GROUP BY
										 SalePrice, 
										 SaleDate,
										 LegalReference
							ORDER BY UniqueID) as row_num      -- The function 'ROW_NUMBER' must have an OVER clause with ORDER BY.
FROM PortfolioProject1.dbo.NashvilleHousing
)
--WHERE row_num > 1    ->Does not work to find duplicates as row_num is Window produced. Use CTE instead
SELECT * FROM RowNumCTE  -- Can now replace SELECT with DELETE
WHERE row_num > 1 -- can now use row_num as it is in memory, result produces duplicates.



/* Delete unused columns */
  -- Generally only do in Views not on working database

/*SELECT * FROM PortfolioProject1.dbo.NashvilleHousing

ALTER TABLE PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate */

