#import "template/template/conf.typ": conf
#import "settings.typ": *

#show: conf.with(
  info: (
    title: "自然语言处理",
    author: "NH5",
    data: datetime.today(),
    cover-image: "/template/assets/coverimage.jpg"
  )
)

#show: setup-math

#include "01-Entropy.typ"
#include "02-FormalLanguageAutomaton.typ"
#include "03-HiddenMarkovModel.typ"
#include "04-ConditionalRandomField.typ"