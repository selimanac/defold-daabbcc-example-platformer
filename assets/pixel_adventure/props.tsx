<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.10" tiledversion="1.11.2" name="props" tilewidth="64" tileheight="64" tilecount="19" columns="0">
 <grid orientation="orthogonal" width="1" height="1"/>
 <tile id="1" type="TRAMPOLINE">
  <image source="Traps/Trampoline/trampoline_idle.png" width="27" height="27"/>
 </tile>
 <tile id="2" type="SPIKES">
  <image source="Traps/Spikes/spikes.png" width="16" height="8"/>
 </tile>
 <tile id="4" type="SPIKE_HEAD">
  <image source="Traps/Spike Head/Idle.png" width="43" height="43"/>
 </tile>
 <tile id="7" type="FALLING_PLATFORM">
  <image source="Traps/Falling Platforms/Off.png" width="32" height="10"/>
 </tile>
 <tile id="15" type="PLAYER">
  <image source="Main Characters/Virtual Guy/Idle (32x32)/00_Idle (32x32).png" width="32" height="32"/>
 </tile>
 <tile id="16" type="APPLE">
  <image source="Items/Fruits/apple/images/apple_01.png" width="32" height="32"/>
 </tile>
 <tile id="17" type="BOX_1">
  <image source="Items/Boxes/Box1/box1_idle.png" width="20" height="20"/>
 </tile>
 <tile id="18" type="CHECKPOINT">
  <image source="Items/Checkpoints/Checkpoint/checkpoint_no_flag.png" width="64" height="64"/>
 </tile>
 <tile id="19" type="FIRE">
  <image source="Traps/Fire/fire_idle.png" width="16" height="32"/>
  <objectgroup draworder="index" id="2">
   <object id="2" x="0" y="16" width="16" height="4"/>
  </objectgroup>
 </tile>
 <tile id="20" type="ENEMY">
  <properties>
   <property name="direction_x" type="int" value="0"/>
   <property name="direction_y" type="int" value="0"/>
   <property name="speed" type="int" value="100"/>
  </properties>
  <image source="Enemies/AngryPig/angry_pig.png" width="33" height="27"/>
 </tile>
 <tile id="21" type="DIRECTION_DOWN">
  <image source="direction_down.png" width="16" height="16"/>
 </tile>
 <tile id="22" type="DIRECTION_LEFT">
  <image source="direction_left.png" width="16" height="16"/>
 </tile>
 <tile id="23" type="DIRECTION_RIGHT">
  <image source="direction_right.png" width="16" height="16"/>
 </tile>
 <tile id="24" type="DIRECTION_UP">
  <image source="direction_up.png" width="16" height="16"/>
 </tile>
 <tile id="25" type="ENEMY">
  <properties>
   <property name="direction_x" type="int" value="0"/>
   <property name="direction_y" type="int" value="0"/>
   <property name="speed" type="int" value="100"/>
  </properties>
  <image source="Traps/Rock Head/Irockheadidle.png" width="32" height="32"/>
 </tile>
 <tile id="26" type="MOVING_PLATFORM">
  <properties>
   <property name="direction_x" type="int" value="0"/>
   <property name="direction_y" type="int" value="0"/>
   <property name="speed" type="int" value="100"/>
  </properties>
  <image source="Traps/Platforms/moving_platform.png" width="32" height="7"/>
 </tile>
 <tile id="27" type="END">
  <image source="Items/Checkpoints/images/end_01.png" width="64" height="64"/>
 </tile>
 <tile id="28" type="WATER">
  <image source="water.png" width="32" height="32"/>
 </tile>
 <tile id="29" type="WATERFALL">
  <image source="waterfall.png" width="32" height="32"/>
 </tile>
</tileset>
