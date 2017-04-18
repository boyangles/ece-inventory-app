## Evolution 4 Deployment Guide

Our software, the Spicy Software ECE Inventory System, is a web application built using the Ruby on Rails framework.

One key feature of the Ruby on Rails stack is that it favors convention over configuration, meaning that it provides users with default structures for a database and the web pages themselves, based on the Model-View-Controller (MVC) framework.

The database used by Spicy Software Inc. is PostgreSQL, but main database operations are performed by ActiveRecord, which provides default database operations without having the user to interact with the database directly.

The ECE Inventory system is composed of several interacting model classes, listed in the table below.


The database consists of tables with the model classes as the primary (lookup) key. The fields of these tables include all the fields of the model classes. Table 1 below displays each model class along with its attributes, such that there is a table for each model class. For instance, the fields of the item class include the unique name, model number, quantity, location, and the description of the item. 

| Model Class |                                                       Fields                                                       |
|-------------|:------------------------------------------------------------------------------------------------------------------:|
| User        | username, password_digest, email, created_at, updated_at, status, privilege, auth_token |
| Item        | unique_name, quantity, quantity_on_loan, model_number, description, location, status, last_action, has_stocks, minimum_stock, stock_threshold_tracked                                                       |
| Stock | item_id, available, serial_tag |
| Custom_Field | field_name, private_indicator, field_type, is_stock | 
| Item_Custom_Field | item_id, custom_field_id, short_text_content, long_text_content, integer_content, float_content|
| Stock_Custom_Field | stock_id, custom_field_id, short_text_content, long_text_content, integer_content, float_content |
| Tag         | name                                                                                    |
| Item_Tag   | tag_id, item_id                                                                            |
| Request     | reason, created_at, updated_at, status, response, user_id, request_initiator   |
| Request_Item | request_id, item_id, created_at, updated_at, quantity_loan, quantity_disburse, quantity_return, bf_status |
| Request_Item_Stocks | stock_id, request_item_id, status |
| Request_Item_Comments | request_item_id, user_id, comment |
| Attachment | request_item_id, doc_file_name, doc_content_type, doc_file_size, doc_updated_at |
| Log        | created_at, user_id, log_type|
| User_Log | log_id, user_id, action, old_privilege, new_privilege |
| Item_Log | log_id, item_id, action, curr_quantity, quantity_change, old_name, new_name, old_desc, new_desc, old_model_num, new_model_num, affected_request, has_stocks|
| Stock_Item_Log | item_log_id, stock_id, curr_serial_tag |
| Request_Log | log_id, request_id, action |
| Stack_Exchange | created_at, updated_at |
| Subscriber | user_id |
| Setting | var, value|

The User, Item, Custom_Field, Tag, Request, and Log refer to items explicitly mentioned in the requirements. The additional fields are to improve and enhance associations and navigation between the classes. They will all be discussed in detail below.

In many cases, a table contains a field that is already a model class. For instance, the Request table contains the fields item_id and user_id. In these cases, a foreign key relation is established to speed-up the lookup of an item in the request table.  

Below we will briefly describe the use of each case in our project and describe their fields.

### Users

A user instance is created for every user in the system, whether their accounts are locally created by admin or linked with a NetID Oauth account. 

##### FIELDS
* **username** - This field must be unique, and is the name displayed with the user on the UI. It is specified by the administrator or it is the NetID of the student. 
* **password_digest** - This is the salted and hashed version of each user's password.
* **created_at**/**updated_at** - These are fields created and maintained by the system, and can be used in logging that note the most recent time the user was created or updated, respectively.
* **email** - Emails are required to be unique. In Evolution 1, we used the email in order to confirm user accounts. This evolution, this functionality has been stripped in favor of the OAuth extensions, but we maintain this record because we foresee that future functionalities may be enhanced by email capabilities. We do require that emails have the *@duke.edu* extension.
* **privilege** - There are three possible enums for privilege: student, manager, and admin. Privileges determine the level of access the users have in the system. Privileges are nested, and will be discussed in more detail later in this guide.
* **status** - By default, users are "approved" when their accounts are created. If at any time in the future, admins or managers desire to deactivate users, that functionality is available. Deactivated users will not be able to login to their accounts at all, and therefore cannot access the system; nevertheless, their records will persist.
* **auth_token** - 

##### ASSOCIATIONS
* has-many REQUESTs
* has-many REQUEST_ITEM_COMMENTs
* has-many USER_LOGs

### Items
Each item instance represents a type of equipment in the inventory system. Items can be created and edited by managers or administrators. 
##### FIELDS
* **unique_name** - This is the name given to an item. As the name suggests, it must be unique. This is the name displayed in the UI for readability.
* **quantity** - This field notes the quantity of the item that is currently in the inventory. This value is decreases when an item is disbursed or loaned out, and increases when an item is returned. This must be an integer.
* * **quantity_on_loan** - This field notes the quantity of the item that is on loan. This value must be an integer.
* **model_number**/**description** - These two fields enhance and provide a further description of each item beyond its name. 
* **location** - This field informs a user of the current location of the item in question.
* **status** - An item can either be active or deactive. A deactive item cannot be requested, disbursed, etc. However, its logged record is maintained and is viewable by administrators. An active item can be subject to all the requirements of this inventory system.
* **last_action** - This field was provided to provide information when logging quantity changes. In this way, quantity change will be associated with an action, and logging can stay automatic within the model. 
* **has_stocks** - This Boolean field is true if the item is per-asset; false if not.
* **stock_threshold_tracked** - This Boolean field is true if the item has a minimum stock; false otherwise.
* **minimum_stock** - This field stores the minimum stock integer of an item.

##### ASSOCIATIONS
* has-many TAGs, through ITEM_TAGs
* has-many ITEM_TAGs
* has-many REQUESTs, through REQUEST_ITEMs
* has-many REQUEST_ITEMs
* has-many CUSTOM_FIELDs, through ITEM_CUSTOM_FIELDs
* has-many ITEM_CUSTOM_FIELDs
* has-many STOCKs
* has-many ITEM_LOGs

### Stocks
Stocks keep track of all the assets of an item, alongside their availability.

##### FIELDS
* **item_id** - This fields tells us which item with which this asset is associated.
* **available** - This Boolean is true if the asset is in stock and becomes false if the item is loaned out; when an item is returned, it is true again. If an item is disbursed or deleted, it is deleted from the table entirely.
* **serial_tag** - This is the 8 digit alphanumeric serial tag used to distinguish assets. All serial_tags are unique.

##### ASSOCIATIONS
* has-many REQUEST_ITEMs, through REQUEST_ITEM_STOCKs
* has-many REQUEST_ITEM_STOCKs
* has-many TAGs, through ITEM_TAGs
* has-many ITEM_TAGs

### Custom_Fields
Custom Fields help define an item beyond the default fields provided by the system. Currently, two pre-loaded custom fields include Location (public) and Restock_Info (private). This table keeps track of all the custom fields created.

##### FIELDS
* **field_name** - This string is the name of the custom field.
* **private_indicator** - This Boolean specifies whether a custom-field is private or not (and therefore whether it is view-able to regular-privilege users).
* **field_type** - This field is an enum, with four possibilities. It must be short_text_type, long_text_type, integer_type, or float_type.
* **is_stock** - This Boolean is true if the custom field is specifically a per-asset custom field. 

##### ASSOCIATIONS
* has-many ITEMS through ITEM_CUSTOM_FIELDs
* has-many ITEM_CUSTOM_FIELDs
* has-many STOCK_CUSTOM_FIELDs

### Item_Custom_Fields
Item Custom Fields holds the actual values of all the custom fields created. Because each custom field can only be one type, three of the four _content fields will always be nil; the non-nil field corresponding with the custom field "field_type" field will hold the value of the field. 

##### FIELDS
* **item_id** - This ID corresponds with the item to which this entry belongs.
* **custom_field_id** - This ID corresponds with the custom_field to which this entry belongs.
* **short_text_content**/**long_text_content**/**integer_content****float_content**   - As mentioned above, three out of four of these fields will always be nil, but the non-nil field will hold the value of the custom field associated with the item specified. 

##### ASSOCIATIONS
* belongs-to CUSTOM_FIELDs
* belongs-to ITEMs

### Stock Custom Fields
Stock Custom Fields holds the actual values of all the custom fields created - for assets. 

##### FIELDS
* **stock_id** - This ID corresponds with the stock to which this entry belongs.
* **custom_field_id** - This ID corresponds with the custom_field to which this entry belongs.
* **short_text_content**/**long_text_content**/**integer_content****float_content**   - Just as in item_custom_fields, three out of four of these fields will always be nil, but the non-nil field will hold the value of the custom field associated with the item specified. 

##### ASSOCIATIONS
* belongs-to STOCKs
* belongs-to CUSTOM_FIELDs

### Tags
Tags help classify items, and are created by administrators. Items are searchable via their tags. 
##### FIELDS
* **name** - This is the unique name that identifies a tag and will be what users use to search for relevant equipment. 

##### ASSOCIATIONS
* has-many ITEMS, through ITEM_TAGS
* has-many ITEM_TAGS

### Item_Tags
Item tags exist to keep track of the many relationships between various items and tags, as there exists a many-to-many relationship between the two items. 

##### FIELDS
* **item_id/tag_id** - Keeps track of the specific item and tag which are associated.

##### ASSOCIATIONS
* belongs-to ITEMs
* belongs-to TAGs

### Requests
Requests are the means through which item disbursements are handled. All users have access to an initial request, referred to as a cart, to which they can add items and corresponding quantities at will. Requests can then be submitted for approval via students or for direct logging of disbursements via managers or administrators. 

##### FIELDS
* **user_id** - This keeps track of the user to whom the request disbursement is going. The administrator or manager who files a request on behalf of another user is not noted directly with the quest, but is noted in the corresponding log entry which is generated. This value must be an integer.
* **created_at**/**updated_at** - Gives the time of creation and updating respectively for requests.
* **status** - Requests have four enum options for requests. At the very beginning, they are "cart"s; every user can only be associated with a single cart. After carts are submitted for approval, they become "outstanding" while they wait for administrative response. If an admin or manager directly submits their cart, or if they approve outstanding requests, those requests become "approved"; admin and managers can also classify requests as "denied".
* **reason** - Users must supply a reason before they are allowed to submit a request. This text area is mandatory. 
* **response** - Administrators are allowed to add a response to a request if they choose to approve or deny an outstanding request.
* **request_initiator** - In most cases, this field is the same as the user_id field. This field would be different in the case of a direct disbursement - in that case, the user_id field would hold the id of the recipient of the request, while this field would hold the id of the manager who created the direct disbursement. This value must be an integer.

##### ASSOCIATIONS
* has-many ITEMS, through REQUEST_ITEMs
* has-many REQUEST_ITEMs
* belongs-to USERs

### Request_Items
Request_Items exist for each instance of an item within a request. This object also keeps track of the quantity of the specific item in the specific request. After the associated request has been approved, we use request_items to track loans, backfills, etc.

##### FIELDS
* **request_id** - This is the id of the request with which the request_item is associated.
* **item_id** - This is the id of the item with which the request_item is associated.
* **quantity_loan** - This field specifies the quantity of the item to be loaned out/which is loaned out in a request. After a request is approved, this value can decrease to zero after the item is returned by the user or disbursed to the user from the admin. If this value is greater than 0, the system keeps track of this request_item as an active loan. This value must be an integer.
* **quantity_disburse** - This field specifies the quantity of the item to be disbursed/which is disbursed in a request. After a request is approved, this value can increase if a manager chooses to disburse items directly from loan. This value must be an integer.
* **quantity_return** - This field specifies the quantity of an item that was loaned out but has been returned into the inventory system. This value must be an integer.
* **bf_status** - This is an enum that tracks the possible backfill states of a loan. The states possible are: loan, bf_request, bf_in_transit (after a backfill has been approved), bf_denied, bf_satisfied, bf_failed.
* **created_at**/**updated_at** - These fields keep track of the date and time at which the request_item is created and updated.

##### ASSOCIATIONS
* belongs-to REQUESTs
* belongs-to ITEMs
* has-many REQUEST_ITEM_STOCKs
* has-many ATTACHMENTs
* has-many REQUEST_ITEM_COMMENTs

### Request_Item_Stocks
These link up the assets with request_items and allow the system to keep track which assets are out on which loan, backfill, disbursement, etc.

##### FIELDS
* **stock_id** - This field tells us which stock is concerned.
* **request_item_id** - This field tells us to which request_item the asset is linked.
* **status** - This enum tells us which action of the request_item to the asset belongs. It is either 'disburse', 'loan', or 'return'; backfills are classified as 'loan' until they are satisfied, at which point they are converted to 'disbursement'.

##### ASSOCIATIONS
* belongs-to REQUEST_ITEMs
* belongs-to STOCKs

### Request_Item_Comments
These are comments that users can make on backfill requests at any time during their lifetime. 

##### FIELDS
* **request_item_id** - This field contains the request_item - and therefore the backfill - with which this comment is associated.
* **user_id** - This field contains the identify of the user who is making the comment.
* **comment** - This field holds the actual text content of the comment.

##### ASSOCIATIONs
* belongs-to REQUEST_ITEMs
* belongs-to USERs

### Attachments
Attachments are the optional PDFs that are uploaded for backfill request. This is achieved in our project using the Paperclip gem; we are able to easily upload and store PDFs while keeping track of their location (url).

##### FIELDS
* **request_item_id** - This tells us which request_item - and therefore which backfill request - this PDF is linked to. 
* **doc_file_name** - This is the name of the file.

##### ASSOCIATIONs
* belongs-to REQUEST_ITEMs


### Logs
This is the overall log table which includes entries for every action taken in the system related to user, item, and request workflow. Logs are automatically generated in the models of each of these classes upon creation and update, and cannot be modified by any user. 

##### FIELDS
* **created_at** - This field reports when logs were created, and is an additional field by which users can search logs.
* **user_id** - This field specifies the user who did the initiating action which caused the corresponding log entry. 
* **log_type** - This is an enum which specifies which object was directly edited to generate this log. Because we do not want to include extraneous columns within the log table in order to accommodate the different classes, this will allow us to query the sub-log tables (item_logs, user_logs, and request_logs) in order to grab the details of each log. The enums for this are "request", "user", and "item".

This object (and most of the log tables) have no associations, due to its split nature.

### User_Logs
User_Logs keeps track of the details of every transaction that has to do with user creation, deletion, or privilege change.

##### FIELDS
* **log_id** - This references the entry in the log table which this user_log belongs to. In this way, we can query the User_Logs in order to find the specific information for any entry in the log table whose log_type is "user".
* **user_id** - This references the specific user whose creation/deletion/privilege-change has caused this automatic logging.
* **action** - This specifies the exact change that the user underwent. User actions have 3 enum options: they can be created, deleted, or have their privilege changed.
* **old_privilege**/**new_privilege** - These field will be checked if the action reported is a privilege change; they track the privileges of the user before and after the change.

### Item_Logs
Item_Logs keeps the specific information related to every transaction that has to do with item creation, deletion, or field change.

##### FIELDS
* **log_id** - This references the entry in the log table which this item_log belongs to. In this way, we can query the Item_Logs in order to find the specific information for any entry in the log table whose log_type is "item".
* **item_id** - This field references the exact item affected by this log.
* **action** - This specifies the exact change that the item underwent. Item actions have 9 enum options: they can be created, deleted, acquired or destroyed, corrected by the administrator (quantity specifically), or had their name/description/model_number updated. In addition, they can be disbursed, loaned, returned, or disbursed_from_loan (included because this workflow is a little different). This allows us to know what to show in the view.
* **curr_quality**/**quantity_change** - These fields reflect the new quantity value of the item and the quality change from the previous value respectively. These values will be accessed if an item is destroyed/lost/disbursed (quantity_change is negative) or acquired (quantity_change is positive), or if an administrator makes a quantity correction.
* **old_name**/**new_name** - These field will be checked if the action reported is a description update; they track the names of the item before and after the change.
* **old_desc**/**new_desc** - These field will be checked if the action reported is a description update; they track the descriptions of the item before and after the change.
* **old_model_num**/**new_model_num** - These field will be checked if the action reported is a description update; they track the model numbers of the item before and after the change.
* **affected_request** - This field is filled in when an item is logged as loaned, disbursed, returned, or disbursed_from_loan: in this way, we can provide more information with each disbursement, loan, or return.
* **has_stocks** - This field is a boolean that is true when the item being logged (at the time of logging) is an asset; otherwise it is false. When it is true, our system is able to go search for the assets whose actions are logged in the Stock_Item_Log table.

##### ASSOCIATIONS
* has-many STOCK_ITEM_LOGs

### Request_Logs
Request_Logs keep track of the details of every transaction that has to do with a request status change, from cart to outstanding, cancelled, approved, and/or denied.
log_id, request_id, action
##### FIELDS
* **log_id** - This references the entry in the log table which this request_log belongs to. In this way, we can query the Request_Logs in order to find the specific information for any entry in the log table whose log_type is "request".
* **request_id** - This references the specific request whose status change has caused this automatic logging.
* **action** - This specifies the exact change that the request underwent. Request actions have 4 options: they can be "placed" (when the carts are submitted), approved, denied, or cancelled.

### Stack Exchanges
Stack Exchanges is a class provided by OAuth in order to allow for NetID login functionality. We do not touch Stack Exchanges.

### Subscribers
A manager can add or take himself off the subscriber list. If a manager is subscribed, he/she will receive an email every time a request is made.

##### FIELDS
* **user_id** - This references the entry in the users table which this subscriber belongs to. In this way, we can query the user in order to find the specific details of any user who is subscribed.

### Settings
Settings are currently used to log all the settings regarding emails. Currently in Evolution 3, there are 3 main settings: the email subject tag, email body, and dates that the email will be sent out. 
However, the use of settings will not necessarily be limited to emails in the future; Settings utilize key-value pairs which can be used to record the state of any variable.

##### FIELDS
* **var** - This string references a particular variable's key.
* **value** - This string references a particular variable's value.


 
 
 

## Configuring a Development Environment

Because we are using the Ruby on Rails framework on a PostgreSQL database, anyone with Ruby 2.3.3, Rails 5.0.1, and Postgres 0.19.0 installed can run our program locally. 

Assuming that those programs are configured correctly, a developer can then navigate into the project directory and enter 

    rails s

into the command line. Then the developer can navigate to 

    https://localhost:3000

and see the local copy of the project, with all local changes.

For information about deploying our project onto a remote server, please refer to the our [deployment guide](DeploymentGuide.md). 

## Install System from Scratch using Backed Up Data
To install the system from scratch using backed up data, first refer to the  [deployment guide](DeploymentGuide.md) for setting up your environment.
Then, once everything is ready, locate your database backup file, and follow the steps in the [backup guide]{BackupGuide.md} under "To Restore Database"

## Testing
There are two separate test suites, a Rails test suite and an Rspec/Capybara suite. </br>
- test rails: ```rails test``` 
- test rspec: ```bundle exec rspec```


The rails tests focus on controller and model back end validations. The rspec tests use the Capybara framework to leverage Selenium testing, simulating the clicks and inputs that a real user would do. With Capybara, we can test real Feature Use Cases. 
</br>The upside is that we have a sort of 'acceptance' testing with this framework, ensuring all the buttons can be clicked, without delving deep into the back end. The tradeoff is that feature tests take a considerably longer amount of time to run, which, in a larger project, is not ideal for continuous integration. 


The Pry gem helps debug and write capybara tests more efficiently, as you can debug inside of a test, as opposed to running the suite/test file multiple times. 


