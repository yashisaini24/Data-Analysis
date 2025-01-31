/*

Cleaning Data in SQL Queries

*/


Select *
From `HousingData.NashvilleHousing`

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT FORMAT_DATE('%d-%m-%Y', PARSE_DATE('%b %d, %Y', SaleDate)) AS formatted_date
from `HousingData.NashvilleHousing`

CREATE OR REPLACE TABLE covid-portfolio-project-449414.HousingData.NashvilleHousing AS
SELECT *,
  FORMAT_DATE('%d-%m-%Y', PARSE_DATE('%b %d, %Y',  SaleDate)) AS formatted_date
from `HousingData.NashvilleHousing`

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select uniqueid
From HousingData.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress) AS NewAddress
From HousingData.NashvilleHousing a
JOIN HousingData.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.`UniqueID`<>b.`UniqueID`
Where a.PropertyAddress is null


/*UPDATE HousingData.NashvilleHousing a
SET PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM HousingData.NashvilleHousing b
WHERE a.ParcelID = b.ParcelID
AND a.uniqueid <> b.uniqueid
AND a.PropertyAddress IS NULL;*/


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From HousingData.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
  LEFT(PropertyAddress, STRPOS(PropertyAddress, ',') - 1) AS Address,  -- Extract part before the comma
  RIGHT(PropertyAddress, LENGTH(PropertyAddress) - STRPOS(PropertyAddress, ',')) AS City -- Extract part after the comma
FROM HousingData.NashvilleHousing;

SELECT OwnerAddress from HousingData.NashvilleHousing

SELECT
  SPLIT(OwnerAddress, ',')[SAFE_OFFSET(0)] AS Address, -- Extracts the first part
  SPLIT(OwnerAddress, ',')[SAFE_OFFSET(1)] AS City, -- Extracts the second part
  SPLIT(OwnerAddress, ',')[SAFE_OFFSET(2)] AS State  -- Extracts the third part
FROM HousingData.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Finding Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
          uniqueid
					) row_num

From HousingData.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

