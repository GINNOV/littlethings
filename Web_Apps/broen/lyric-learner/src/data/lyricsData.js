// FILE: src/data/lyricsData.js
// This file exports the data object for the song, keeping the content separate from the logic.

export const songData = {
  title: "Mrs. Robinson",
  author: "Simon & Garfunkel",
  layers: {
    1: { name: "Core Vocabulary", color: "#EBF8FF", textColor: "#2A4365" },
    2: { name: "Descriptive Words", color: "#F0FFF4", textColor: "#22543D" },
    3: { name: "Abstract & Figurative", color: "#FFFBEB", textColor: "#744210" },
    4: { name: "Cultural References", color: "#F9F5FF", textColor: "#44337A" },
  },
  stanzas: [
    [
      { text: "And", layer: 1, example: "You and me." }, { text: "here's", layer: 1, example: "Here's your book." }, { text: "to", layer: 1, example: "Go to the store." }, { text: "you,", layer: 1, example: "This is for you." }, { text: "Mrs.", layer: 4, example: "Mrs. Smith is a teacher." }, { text: "Robinson,", layer: 4, example: "The Robinson family lives here." },
    ],
    [
      { text: "Jesus", layer: 3, example: "A central figure in Christianity." }, { text: "loves", layer: 3, example: "A mother loves her child." }, { text: "you", layer: 1, example: "This is for you." }, { text: "more", layer: 1, example: "I would like more coffee." }, { text: "than", layer: 1, example: "He is taller than me." }, { text: "you", layer: 1, example: "This is for you." }, { text: "will", layer: 1, example: "I will see you tomorrow." }, { text: "know.", layer: 1, example: "I know the answer." },
    ],
    [
      { text: "God", layer: 1, example: "Many people pray to God." }, { text: "bless", layer: 1, example: "God bless you." }, { text: "you", layer: 1, example: "This is for you." }, { text: "please,", layer: 1, example: "Can you help me, please?" }, { text: "Mrs.", layer: 4, example: "Mrs. Smith is a teacher." }, { text: "Robinson.", layer: 4, example: "The Robinson family lives here." },
    ],
    [
      { text: "Heaven", layer: 3, example: "A place of peace." }, { text: "holds", layer: 2, example: "She holds the baby." }, { text: "a", layer: 1, example: "I see a bird." }, { text: "place", layer: 2, example: "This is a nice place." }, { text: "for", layer: 1, example: "A gift for you." }, { text: "those", layer: 1, example: "I like those shoes." }, { text: "who", layer: 1, example: "The person who called." }, { text: "pray,", layer: 1, example: "They pray every night." },
    ],
    [
      { text: "Hey,", layer: 1, example: "Hey, how are you?" }, { text: "hey,", layer: 1, example: "Hey, listen!" }, { text: "hey.", layer: 1, example: "Hey, stop!" },
    ],
    [
      { text: "We'd", layer: 1, example: "We'd like to go." }, { text: "like", layer: 1, example: "I like ice cream." }, { text: "to", layer: 1, example: "Go to the store." }, { text: "know", layer: 1, example: "I know the answer." }, { text: "a", layer: 1, example: "I see a bird." }, { text: "little", layer: 2, example: "Just a little sugar." }, { text: "bit", layer: 2, example: "Wait a bit." }, { text: "about", layer: 1, example: "Tell me about your day." }, { text: "you", layer: 1, example: "This is for you." }, { text: "for", layer: 1, example: "A gift for you." }, { text: "our", layer: 1, example: "This is our house." }, { text: "files.", layer: 2, example: "Put this in the files." },
    ],
    [
      { text: "We'd", layer: 1, example: "We'd like to go." }, { text: "like", layer: 1, example: "I like ice cream." }, { text: "to", layer: 1, example: "Go to the store." }, { text: "help", layer: 2, example: "Can you help me?" }, { text: "you", layer: 1, example: "This is for you." }, { text: "learn", layer: 2, example: "I want to learn." }, { text: "to", layer: 1, example: "Go to the store." }, { text: "help", layer: 2, example: "Can you help me?" }, { text: "yourself.", layer: 2, example: "You must do it yourself." },
    ],
    [
      { text: "Look", layer: 2, example: "Look at the sky." }, { text: "around", layer: 2, example: "Look around you." }, { text: "you,", layer: 1, example: "This is for you." }, { text: "all", layer: 1, example: "All of them are here." }, { text: "you", layer: 1, example: "This is for you." }, { text: "see", layer: 2, example: "I see a car." }, { text: "are", layer: 1, example: "You are my friend." }, { text: "sympathetic", layer: 3, example: "He has a sympathetic ear." }, { text: "eyes.", layer: 2, example: "She has blue eyes." },
    ],
    [
      { text: "Stroll", layer: 2, example: "Let's stroll through the park." }, { text: "around", layer: 2, example: "Look around you." }, { text: "the", layer: 1, example: "The dog is happy." }, { text: "grounds", layer: 2, example: "The school grounds are large." }, { text: "until", layer: 2, example: "Wait until I get back." }, { text: "you", layer: 1, example: "This is for you." }, { text: "feel", layer: 3, example: "How do you feel?" }, { text: "at", layer: 1, example: "We are at home." }, { text: "home.", layer: 1, example: "This is my home." },
    ],
    [
      { text: "Where", layer: 1, example: "Where are you going?" }, { text: "have", layer: 1, example: "I have a pen." }, { text: "you", layer: 1, example: "This is for you." }, { text: "gone,", layer: 2, example: "He has gone home." }, { text: "Joe", layer: 4, example: "Joe is a common name." }, { text: "DiMaggio?", layer: 4, example: "A famous baseball player." },
    ],
    [
      { text: "A", layer: 1, example: "I see a bird." }, { text: "nation", layer: 4, example: "Our nation is large." }, { text: "turns", layer: 2, example: "The world turns." }, { text: "its", layer: 1, example: "The cat licked its paw." }, { text: "lonely", layer: 3, example: "He felt lonely." }, { text: "eyes", layer: 2, example: "She has blue eyes." }, { text: "to", layer: 1, example: "Go to the store." }, { text: "you.", layer: 1, example: "This is for you." },
    ],
    [
      { text: "Woo,", layer: 1, example: "An expression of excitement." }, { text: "woo,", layer: 1, example: "An expression of excitement." }, { text: "woo.", layer: 1, example: "An expression of excitement." },
    ],
    [
      { text: "What's", layer: 1, example: "What's your name?" }, { text: "that", layer: 1, example: "I like that car." }, { text: "you", layer: 1, example: "This is for you." }, { text: "say,", layer: 1, example: "What did you say?" }, { text: "Mrs.", layer: 4, example: "Mrs. Smith is a teacher." }, { text: "Robinson?", layer: 4, example: "The Robinson family lives here." },
    ],
    [
      { text: "Joltin'", layer: 4, example: "A nickname meaning powerful." }, { text: "Joe", layer: 4, example: "Joe is a common name." }, { text: "has", layer: 1, example: "She has a new car." }, { text: "left", layer: 2, example: "He left the room." }, { text: "and", layer: 1, example: "You and me." }, { text: "gone", layer: 2, example: "He has gone home." }, { text: "away.", layer: 2, example: "The bird flew away." },
    ],
    [
      { text: "Hey,", layer: 1, example: "Hey, how are you?" }, { text: "hey,", layer: 1, example: "Hey, listen!" }, { text: "hey.", layer: 1, example: "Hey, stop!" },
    ],
  ],
};
