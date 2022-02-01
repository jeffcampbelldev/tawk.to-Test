# tawk.to-iOS-Test

Tasks Completed 

USER
1. Fetch Users List from https://api.github.com/users?since=0
2. Pagination of the Users List
3. Dynamic Page Size
4. Display a spinner while loading data as the last list item.
5. Every fourth avatar's colour have its (image) colours inverted.
6. List item view have a note icon if there is note information saved for the given user.
7. Searchable Users list - (local search) only; based on username and note
8. List (table/collection view) must be implemented using at least 3 different cells
(normal, note & inverted) and Protocols.

PROFILE
1. Obtained profile from https://api.github.com/users/[username] in JSON format
2. View with user's avatar as a header view followed by information fields.
3. Save and retrieve notes of user's in CoreData

GitHub
1. The app works offline if data has been previously loaded.
2. The app handle no internet scenario amd show appropriate UI indicators.
3. The app automatically retry loading data once the connection is available.

TEST
1. Unit tests using XCTest library for validate creation & update in CoreData.

BONUS
1. Empty views (while data is still loading) have Loading Shimmer
2. Any data fetch should utilize Result types.
3. MVVM patterns are used.
4. When there is data available (saved in the database) from previous launches, that
   data is displayed first, then (in parallel) new data is be fetched from the backend.
