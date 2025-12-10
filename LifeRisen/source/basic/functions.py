
import math
math_things = ('pi', 'degrees', 'radians', 'sin', 'cos', 'atan2', 'sqrt', 'hypot', 'floor', 'ceil')
for math_thing in math_things: globals()[math_thing] = getattr(math, math_thing)
del math_things

import random
random_instance = random.Random()
random_things = ('random', 'randint', 'choice', 'uniform', 'getrandbits', 'choices')
for random_thing in random_things: globals()[random_thing] = getattr(random_instance, random_thing)
del random_instance, random_things

check_input = lambda self, i: hasattr(self, i) and not self[i] == int()

def seconds_string(seconds: float) -> str:
  seconds = int(seconds)
  minutes, seconds = divmod(seconds, 60)
  hours, minutes = divmod(minutes, 60)
  return '{:02d}:{:02d}:{:02d}'.format(hours, minutes, seconds) if hours < 24 else '💀'

oscillate = lambda amplitude, frequency, time, wave: amplitude * wave(2 * pi * frequency * time)
wave = lambda amplitude, frequency, time, wave: amplitude * wave(time * frequency)

