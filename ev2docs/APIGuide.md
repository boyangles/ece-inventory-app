# Spicy Software Inc., Inventory System API #

# Sessions API #
----------

## SESS-1: Login to a Session ##

### *POST /api/sessions* ###

### Brief Description ###
Creates an authentication token for a newcomer to the website. The authentication token is randomly generated and is associated with a user account. Further interaction with the user API requires use of the entered alphanumeric token as an Authorization header.

Parameter  	  | Description							| Data Type
------------- | -------------						| -------------
Email		  | User email address					| String
Password	  | Password associated with user		| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------						
200			  		| OK					
401					| Unauthorized
422	  				| Unprocessable Entity

### Sample Outputs ###

**Successful Login (200)**
```javascript
{
  id: 13,
  email: "exampleapproved-1@example.com",
  permission: "admin",
  authorization: "MRM_kQsq4TD61QRaVNN_"
}
```

**Incorrect Username/Password (422)**
```javascript
{
  errors: "Invalid username or password"
}
```

**Account has been deactivated (401)**
```javascript
{
  errors: "Your account has not been approved by an administrator"
}
```		

## SESS-2 Logout of a Session ##

### *GET /api/custom_fields* ###

### Brief Description ###
Removes your authorization token, creating a randomly generated alphanumerical token that is not shown as output.


Parameter  	  | Description							| Data Type
------------- | -------------						| -------------
id			  | Authorization Token					| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
204					| No Content
422	  				| Unprocessable Entity

### Sample Outputs ###

**Successful Session Deletion (204)**
```javascript
no content
```

**Incorrect Authorization Token (422)**
```javascript
{
  errors: "Invalid authorization token"
}
```

# CustomFields API #
----------

## CF-1 Show Specified Custom Fields ##

### *GET /api/custom_fields* ###

### Brief Description ###
Queries all available custom fields and returns as JSON if no query parameters specified. Otherwise, queries by query parameters.


Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
id			  | Authorization Token		| String
Field Name	  | Name of the Field		| String
Private?	  | Determines if students may see this field | Boolean
Field Type	  |	Content Type of Field	| Enum [short_text_type, long_text_type, integer_type, float_type] 

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
422	  				| Unprocessable Entity

### Sample Outputs ###

**Correct Query (200)**
```javascript
[
  {
    "id": 1,
    "field_name": "location",
    "private_indicator": false,
    "field_type": "short_text_type"
  },
  {
    "id": 2,
    "field_name": "restock_info",
    "private_indicator": true,
    "field_type": "long_text_type"
  }
]
```

## CF-2 Create Custom Fields ##

### *POST /api/custom_fields* ###

### Brief Description ###
Admins may create a new custom field that is available for all items to reference.

Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
id			  | Authorization Token		| String
Field Name	  | Name of the Field		| String
Private?	  | Determines if students may see this field | Boolean
Field Type	  |	Content Type of Field	| Enum [short_text_type, long_text_type, integer_type, float_type]  

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
201					| Created
401					| Unauthorized
422	  				| Unprocessable Entity

### Sample Outputs ###

**Successful Custom Field Creation (200)**
```javascript
{
  "id": 3,
  "field_name": "rarity",
  "private_indicator": false,
  "field_type": "long_text_type"
}
```
## CF-3 DELETE Custom Fields ##

### *DELETE /api/custom_fields/{id}* ###

### Brief Description ###
Admins may delete a custom field, cascading deletion of all the item association.

Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
header	  	  | Authorization Token		| String
id			  | Custom Field ID			| Integer

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
201					| Created
401					| Unauthorized
404					| Not found
422	  				| Unprocessable Entity

### Sample Outputs ###

**Successful CustomField Deletion (204)**
```javascript
{
  "id": 3,
  "field_name": "rarity",
  "private_indicator": false,
  "field_type": "long_text_type"
}
```

## CF-4 Fetches a specific CustomField ##

### *GET /api/custom_fields/{id}* ###

### Brief Description ###
Admins/Managers may view any particular custom field. Students may only view public custom fields. Query by custom field id.

Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
header	  	  | Authorization Token		| String
id			  | Custom Field ID			| Integer

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404					| Not found

### Sample Outputs ###

**Successful CustomField Fetch (200)**
```javascript
{
  "id": 1,
  "field_name": "location",
  "private_indicator": false,
  "field_type": "short_text_type"
}
```

## CF-5 Updates the name of a CustomField ##

### *PUT/PATCH /api/custom_fields/{id}/update_name* ###

### Brief Description ###
Admins may change the name of a custom field.


Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
header	  	  | Authorization Token		| String
id			  | Custom Field ID			| Integer
Field Name	  | Custom Field Name		| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404					| Not found
422					| Unprocessable Entity

### Sample Outputs ###

**Successful CustomField Name Update (200)**
```javascript
{
  "id": 1,
  "field_name": "finally",
  "private_indicator": false,
  "field_type": "short_text_type"
}
```

## CF-6 Updates the privacy of a CustomField ##

### *PUT/PATCH /api/custom_fields/{id}/update_privacy* ###

### Brief Description ###
Admins may change the privacy of a custom field.


Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
header	  	  | Authorization Token		| String
id			  | Custom Field ID			| Integer
Private?	  | Custom Field Private?	| Boolean

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404					| Not found
422					| Unprocessable Entity

### Sample Outputs ###

**Successful CustomField Type Update (200)**
```javascript
{
  "id": 1,
  "field_name": "location",
  "private_indicator": true,
  "field_type": "short_text_type"
}
```

## CF-7 Updates the type of a CustomField ##

### *PUT/PATCH /api/custom_fields/{id}/update_type* ###

### Brief Description ###
Admins may change the type of a custom field. As a side effect, All associated 


Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
header	  	  | Authorization Token		| String
id			  | Custom Field ID			| Integer
Type 		  | Custom Field Type 		| Enum [short_text_type, long_text_type, integer_type, float_type]  

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404					| Not found
422					| Unprocessable Entity

### Sample Outputs ###

**Successful CustomField Type Update (200)**
```javascript
{
  "id": 1,
  "field_name": "location",
  "private_indicator": true,
  "field_type": "long_text_type"
}
```

# Tags API #
----------

## TAG-1 Obtains all or specified tags ##

### *GET /api/tags* ###

### Brief Description ###
Admins may change the type of a custom field. As a side effect, All associated 


Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
header	  	  | Authorization Token		| String
name		  |	Query param for Tag		| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized

### Sample Outputs ###

**Successful Searching Tags (200)**
```javascript
[
  {
    "id": 4,
    "name": "Resistor",
    "created_at": "2017-02-28T07:24:56.123Z",
    "updated_at": "2017-02-28T07:24:56.123Z"
  }
]
```

## TAG-2 Create a new tag ##

### *POST /api/tags* ###

### Brief Description ###
Admins may create their own tags for association later with items 


Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
header	  	  | Authorization Token		| String
name		  |	Tag Name				| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized

### Sample Outputs ###

**Create New Tags (200)**
```javascript
{
  "id": 7,
  "name": "test name",
  "created_at": "2017-02-28T11:14:26.253Z",
  "updated_at": "2017-02-28T11:14:26.253Z"
}

```

## TAG-3 Delete a tag ##

### *DELETE /api/tags/{:id}* ###

### Brief Description ###
Admins may view all tags 


Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
header	  	  | Authorization Token		| String
id			  |	Tags ID 				| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
200					| OK
401					| Unauthorized
404 				| Not Found

## TAG-4 Obtain a specified tag ##

### *SHOW /api/tags/{:id}* ###

### Brief Description ###
Admins may create their own tags for association later with items 


Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
header	  	  | Authorization Token		| String
id			  |	Tags ID 				| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
204					| No Content
401					| Unauthorized
404 				| Not Found

## TAG-4 Update a specific tag ##

### *PATCH /api/tags/{:id}* ###

### Brief Description ###
Admins may change name of an existing tag


Parameter  	  | Description				| Data Type
------------- | -------------			| -------------
header	  	  | Authorization Token		| String
id			  |	Tags ID 				| Integer
name		  | Tags Name				| String

### Response Messages ###
HTTP Status Code	| Reasons						
------------- 		| -------------											
204					| No Content
401					| Unauthorized
404 				| Not Found

# Users API #
----------

## USERS-1 Update Password ##

### *PUT/PATCH /api/users/{id}/update_password* ###

### Brief Description ###
Only users updating their own passwords may access this function.

![](http://i.imgur.com/Jd06WR1.png)

## USERS-2 Update Status ##

### *PUT/PATCH /api/users/{id}/update_status* ###

### Brief Description ###
Admins may update the status of others

![](http://i.imgur.com/0SOEqI0.png)

## USERS-3 Update Privilege ##

### *PUT/PATCH /api/users/{id}/update_privilege* ###

### Brief Description ###
Admins may update the privilege of users but not themselves

![](http://i.imgur.com/5H4tBLL.png)

## USERS-4 Index ##

### *GET /api/users/index* ###

### Brief Description ###
Admins access all users

![](http://i.imgur.com/LQdQbwD.png)

## USERS-5 New User ##

### *POST /api/users* ###

![](http://i.imgur.com/OTKpu3G.png)

## USERS-5 Delete User ##

### *DELETE /api/users/{id}* ###

![](http://i.imgur.com/7Ljj7QC.png)

## USERS-6 Show Particular User ##

### *SHOW /api/users/{id}* ###

![](http://i.imgur.com/XlOO2bc.png)

# Items API #
----------

![](http://i.imgur.com/3z36jTX.png)
![](http://i.imgur.com/IoeHmfT.png)
![](http://i.imgur.com/C6y1jzP.png)
![](http://i.imgur.com/2Ye9vHi.png)
![](http://i.imgur.com/B1zvsok.png)
![](http://i.imgur.com/yit5Heb.png)
![](http://i.imgur.com/7Ga9Y4y.png)
![](http://i.imgur.com/cIQKbva.png)
![](http://i.imgur.com/7pRSswK.png)
![](http://i.imgur.com/FB6Tufw.png)
# Requests API #
----------
![](http://i.imgur.com/65IxfnK.png)
![](http://i.imgur.com/Cmoe6HD.png)
![](http://i.imgur.com/K8wXjcG.png)
![](http://i.imgur.com/7YLkOHn.png)
![](http://i.imgur.com/HGdCpSm.png)
![](http://i.imgur.com/wbirynw.png)

# Logs API #
----------
![](http://i.imgur.com/6zRyB8P.png)
![](http://i.imgur.com/hbHk5Iz.png)