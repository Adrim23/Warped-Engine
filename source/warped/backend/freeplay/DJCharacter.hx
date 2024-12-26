package warped.backend.freeplay;
import warped.backend.freeplay.FreeplayData.PlayerData;
import warped.backend.freeplay.FreeplayData.PlayerFreeplayDJData;

/**
 * An object used to retrieve data about a playable character (also known as "weeks").
 * Can be scripted to override each function, for custom behavior.
 */
@:nullSafety
class DJCharacter
{

  /**
   * Playable character data as parsed from the JSON file.
   */
  public final _data:Null<PlayerData>;

  /**
   * @param id The ID of the JSON file to parse.
   */
  public function new(data:PlayerData)
  {
    _data = data;
  }

  /**
   * Retrieve the readable name of the playable character.
   */
  public function getName():String
  {
    // TODO: Maybe add localization support?
    return _data?.name ?? "Unknown";
  }

  /**
   * Retrieve the list of stage character IDs associated with this playable character.
   * @return The list of associated character IDs
   */
  public function getOwnedCharacterIds():Array<String>
  {
    return _data?.ownedChars ?? [];
  }

  /**
   * Return `true` if, when this character is selected in Freeplay,
   * songs unassociated with a specific character should appear.
   */
  public function shouldShowUnownedChars():Bool
  {
    return _data?.showUnownedChars ?? false;
  }

  public function shouldShowCharacter(id:String):Bool
  {
    if (getOwnedCharacterIds().contains(id))
    {
      return true;
    }

    return false;
  }

  public function getFreeplayStyleID():String
  {
    return _data?.freeplayStyle ?? 'bf';
  }

  public function getFreeplayDJData():Null<PlayerFreeplayDJData>
  {
    return _data?.freeplayDJ;
  }

  public function getFreeplayDJText(index:Int):String
  {
    // Silly little placeholder
    return _data?.freeplayDJ?.getFreeplayDJText(index) ?? 'GET FREAKY ON A FRIDAY';
  }

  /**
   * Returns whether this character is unlocked.
   */
  public function isUnlocked():Bool
  {
    return _data?.unlocked ?? true;
  }

  /**
   * Called when the character is destroyed.
   * TODO: Document when this gets called
   */
  public function destroy():Void {}
}