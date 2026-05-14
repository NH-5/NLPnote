#import "template/template/conf.typ": conf
#import "settings.typ": *

#show: conf.with(
  info: (
    title: "自然语言处理",
    author: "NH5",
    data: datetime.today(),
    cover-image: "/typst/template/assets/coverimage.jpg"
  )
)

#show: setup-math

#include "01-Entropy.typ"
#include "02-FormalLanguageAutomaton.typ"
#include "03-HiddenMarkovModel.typ"
#include "04-ConditionalRandomField.typ"
#include "05-LanguageModel.typ"
#include "06-Corpus.typ"
#include "07-LMwithNeuralNetwork.typ"
#include "08-InformationRetrieval.typ"
#include "09-LexicalAnalysis.typ"
#include "10-SyntaxAnalysis.typ"
