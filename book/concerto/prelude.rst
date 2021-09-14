*********************
Prelude
*********************

This is a short book about making music in LiveCore.

=================
What is LiveCore?
=================

LiveCore is a livecoding system for modular realtime audio synthesis. It's not
the first in this genre, you might have encountered Extempore, SuperCollider,
Sporth, to name a few. However, this space inherently forces you choose a set of
trade-offs that makes each system unique.

If you are not familiar with the topic, fear not. Let's unpack what "livecoding
system for modular realtime audio synthesis" means. "Audio synthesis" means that
we are focused on creating audio from scratch rather than processing and mixing
recordings. One can use recorded samples in LiveCore and other systems I
mentioned but this is not a primary focus. "Realtime" cues that we are not
generating audio file first and then listening to it but stream the sound as
it's created, and can alter it interactively, not unlike the musical instrument.
"Modular" refers to the fact that most of the audio is created using already
available, composable building blocks. At this point, if you are familiar with
modular synth, you may say that this all sounds very similar to it, and
especially virtual modular synth like VCV Rack. This is not wrong but
"livecoding system" part is what makes a major difference. It's not only saying
that you connect modules by writing code, it implies that you can do custom
processing or even define new modules on the fly, during the performance.

We will talk about LiveCore's place in this space and unique qualities of
livecoding in :doc:`./history` and :doc:`./philosophy`.

========================
What is this book about?
========================

It's a guided tour through the most of the building blocks of LiveCore and the
ways of their composition. By the end of the book we will gradually develop a
piece of experimental generative electronic music, and by this time you should
have enough of LiveCore knowledge to embark on your own creative journey with
it.

======================
How to read this book?
======================

The book is designed to be read in a linear fashion, however, you'll find that
some chapters, or even sections are fairly independent. Once you get a grasp of
what's going on, feel free to work on chapters which fancy you at that
particular moment. The only advice I'd offer is to try all the code samples as
you go through the text, that would help you to build intuition about LiveCore
modus operandi and get familiar with available modules. But please don't feel
limited by these samples, experiment!  LiveCore was created for experiments.
