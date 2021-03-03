import 'package:flutter/material.dart';

import '../dummy_data.dart';

class MealDetailScreen extends StatelessWidget {
  static const routeName = '/meal-detail';
  final Function toggleFavorite;
  final Function isFavorite;

  MealDetailScreen(this.toggleFavorite, this.isFavorite);

  Widget buildSectionTitle(String text, BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          text,
          style: Theme.of(context).textTheme.title,
        ));
  }

  Widget buildContainer({Widget child, double width, double height, EdgeInsets margin}) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        margin: margin,
        padding: EdgeInsets.all(10),
        height: height,
        width: width,
        child: child);
  }

  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments as String;
    final selectedMeal = DUMMY_MEALS.firstWhere((meal) => meal.id == mealId);
    return Scaffold(
        appBar: AppBar(
          title: Text('${selectedMeal.title}'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  height: 300,
                  width: double.infinity,
                  child:
                      Image.network(selectedMeal.imageUrl, fit: BoxFit.cover)
              ),
              buildSectionTitle('Ingredients', context),
              buildContainer(child: ListView.builder(
                  itemBuilder: (ctx, index) => Card(
                      color: Theme.of(context).accentColor,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(selectedMeal.ingredients[index]))),
                  itemCount: selectedMeal.ingredients.length
                  ),
                  width: 350,
                  height: 130,
                  margin: EdgeInsets.all(10)
              ),
              buildSectionTitle('Steps', context),
              buildContainer(child: ListView.builder(
                  itemBuilder: (ctx, index) => Column(
                    children: <Widget>[
                      ListTile(
                          leading: CircleAvatar(child: Text('# ${(index + 1)}')),
                          title: Text(selectedMeal.steps[index])),
                      Divider()
                    ],
                  ),
                  itemCount: selectedMeal.steps.length),
                  width: double.infinity,
                  height: 300,
                  margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10)
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon (isFavorite(mealId) ?
            Icons.star : Icons.star_border
          ),
          onPressed: () => toggleFavorite(mealId),
        ),
        );
  }
}
