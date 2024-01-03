SELECT *
FROM NashvilleHousingData

-- populate property address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousingData AS a
JOIN NashvilleHousingData AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousingData AS a
JOIN NashvilleHousingData AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--splitting up property address info into 3 different columns (address, city, state)

SELECT PropertyAddress
FROM NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD SplitAddress VARCHAR(MAX)

UPDATE NashvilleHousingData
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousingData
ADD SplitCity VARCHAR(MAX)

UPDATE NashvilleHousingData
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousingData

SELECT OwnerAddress
FROM NashvilleHousingData

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress VARCHAR(MAX)

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity VARCHAR(MAX)

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState VARCHAR(MAX)

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

--make SoldAsVacant consistent by changing Y to Yes and N to No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousingData

UPDATE NashvilleHousingData
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--removing duplicates

WITH RowNumCTE AS (
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        ORDER BY
        UniqueID
    ) row_num
FROM NashvilleHousingData
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

-- deleting useless collumns 

SELECT *
FROM NashvilleHousingData

ALTER TABLE NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress