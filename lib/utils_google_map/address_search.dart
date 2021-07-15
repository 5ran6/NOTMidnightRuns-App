import 'package:flutter/material.dart';
import 'package:mealup/utils_google_map/place_service.dart';

class AddressSearch extends SearchDelegate<Suggestion1> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final sessionToken;
  PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  // @override
  // Widget
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: query == ""
          ? null
          : apiClient.fetchLatlong(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title:
                        Text((snapshot.data[index] as Suggestion1).description),
                    onTap: () {
                      close(context, snapshot.data[index] as Suggestion1);
                    },
                  ),
                  itemCount: snapshot.data.length,
                )
              : Container(child: Text('Loading...')),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == ""
          ? null
          : apiClient.fetchLatlong(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title:
                        Text((snapshot.data[index] as Suggestion1).description),
                    onTap: () {
                      close(context, snapshot.data[index] as Suggestion1);
                    },
                  ),
                  itemCount: snapshot.data.length,
                )
              : Container(child: Text('Loading...')),
    );
  }
}
