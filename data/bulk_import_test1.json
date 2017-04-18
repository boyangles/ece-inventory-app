# Evolution 4 Bulk Import Guide #

**Format:** JSON

**Description:** The input is represented as a JSON array of individual JSON objects, each which represents a single item and its associations.

## Input Parameter Descriptions and Restrictions ##

### Overarching Description/Restriction ###
Input must be a JSON array otherwise an error message will be shown. Each JSON object must match the below description and schema below, otherwise a specific error message will be shown.

### "unique_name" ###
**Required**. Corresponds to the name of the item. The input must be a string type and must be unique.

### "quantity" ###
**Required**. Corresponds to the initial quantity of the item. Ensure that the input is greater than or equal to 0 and is an integer.

### "model_number" ###
*Optional*. Must be a string type. Represents the model number of the item.

### "description" ###
*Optional*. Must be a string type. Represents a short description of the item. Ensure that the length is less than 255 character to ensure that the description is "short".

### "tags" ###
**Required**. A JSON array of strings representing tags associated with a specific item. The JSON array must exist even if no tags are specified -- in which case the array is simply empty. Repeated tags are allowed, but the repeated ones are merely ignored. Tags in the array that are do not currently exist are added on the fly.

### "custom_fields" ###
**Required**. A JSON array of JSON objects representing custom fields and their corresponding value associated with a specific item. The JSON array must exist even if no custom_field assignments are specified -- in which case the array is simply empty. Repeated custom_field assignments are allowed; however, only the latest duplicate assignment in array ordering will be updated. Inputted custom field names that do not correspond to an existing field name will result in an error message being shown. If the inputted value for a custom field is specified and is of the wrong type, then a type error message will also be shown to the administrator.

```javascript
"custom_fields": [
  {
    "name": ...,
    "value": ...
  }, ...
]
```

### "has_stocks" ###
**Required**. Must be a boolean type. *True* represents that the corresponding item is per-asset, and *False* represents that it is not per-asset.

### "assets" ###
**Required**. A JSON array of strings representing esrial tags associated with a particular asest. The JSON array must exist even if no serial tags are specified -- in which care the array is simply empty. In the case that the item is per-asset, it is required that the number of elements in this JSON array must equal to the number specified in the quantity field. If not, then a friendly message to the user will show indicating that the numbers don't match.

## Sample Input ##
```javascript
[{
  "unique_name": "test_name_0",
  "quantity": 5,
  "model_number": "5x937s",
  "description": "Sample description 0",
  "tags": ["ECE110", "ECE350", "Outdated"],
  "custom_fields": [
    {
      "name": "price",
      "value": 35
    }, {
      "name": "location",
      "value": "CIEMAS"
    }
  ],
  "has_stocks": true,
  "assets": ["sample01", "sample02", "sample03", "sample04", "sample05"]
}, {
  "unique_name": "test_name_1",
  "quantity": 12,
  "tags": [],
  "custom_fields": [],
  "has_stocks": false,
  "assets": []
}]
```
