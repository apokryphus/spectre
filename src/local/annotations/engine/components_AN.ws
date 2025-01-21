@wrapMethod(CInteractionComponent) function IsEnabledOnHorse() : bool 
{
	if(false) 
	{
		wrappedMethod();
	}

	if( !thePlayer.IsCiri() && thePlayer.IsUsingHorse() )
	{
		return true;
	}
	
	return isEnabledOnHorse; 
}