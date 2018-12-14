var currentScoreBoard = new StringBuilder("37");
var firstElfLocation = 0;
var secondElfLocation = 1;
var puzzleInput = "793031";
while ((currentScoreBoard.Length < puzzleInput.Length + 2) || (currentScoreBoard.ToString(currentScoreBoard.Length - puzzleInput.Length - 2, puzzleInput.Length + 2).IndexOf(puzzleInput) == -1))
{
    var firstElfCurrentRecipeScore = (currentScoreBoard[firstElfLocation] - '0');
    var secondElfCurrentRecipeScore = (currentScoreBoard[secondElfLocation] - '0');
    var newRecipes = firstElfCurrentRecipeScore + secondElfCurrentRecipeScore;
    currentScoreBoard.Append(newRecipes.ToString());
    firstElfLocation = (firstElfLocation + firstElfCurrentRecipeScore + 1) % currentScoreBoard.Length;
    secondElfLocation = (secondElfLocation + secondElfCurrentRecipeScore + 1) % currentScoreBoard.Length;
}

var end = currentScoreBoard.ToString(currentScoreBoard.Length - puzzleInput.Length - 2, puzzleInput.Length + 2);
Console.WriteLine((currentScoreBoard.Length - puzzleInput.Length - 2 + end.IndexOf(puzzleInput)).ToString());
