<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet>

<!--*
    * lists contents of cxchelp tags
    * - used for testing only
    *-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--* output is plain text *-->
  <xsl:output method="text"/>

  <xsl:template match="/">
    <xsl:for-each select="//cxclink[@href]">
<xsl:value-of select="@href"/><xsl:text>
</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
