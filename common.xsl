<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet>

<!--* 
    * Templates that are used by both the ahelp and generic code.
    * The ahelp code should be re-written so that they use the
    * same set up as everything else, but doing this incrementally,
    * and very slowly.
    *
    *-->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:date="http://exslt.org/dates-and-times"
  xmlns:func="http://exslt.org/functions"
  xmlns:djb="http://hea-www.harvard.edu/~dburke/xsl/"
  extension-element-prefixes="date func djb">

  <!--*
      * check that a parameter is not empty, exiting if it is.
      *
      * Parameters:
      *   name - string, required
      *     name of parameter
      *
      *   value - string, required
      *     input value of parameter
      *
      *   template - string, required
      *     name of template
      *
      *-->
  <xsl:template name="check-nonempty-param">
    <xsl:param name="name"/>
    <xsl:param name="value"/>
    <xsl:param name="template"/>

    <xsl:if test="$value = ''">
      <xsl:message terminate="yes">
 Error: <xsl:value-of select="$template"/> called without a <xsl:value-of select="$name"/> parameter
      </xsl:message>
    </xsl:if>

  </xsl:template> <!--* name=check-nonempty-param *-->

  <!--*
      * SAO/SI mandated header items.
      *
      * Also add in the favicon here to make things simpler,
      * if not cleaner/semantically sensible.
      *
      * Uses:
      *    $favicon
      *    $lastmodiso
      *    $site
      *    $desc
      *    info/metalist
      *-->
  <xsl:template name="add-sao-metadata">
    <xsl:param name="title"/>
    <xsl:if test="not(boolean($title))">
      <xsl:message terminate="yes">
 Internal Error: add-sao-metadata called but title parameter not set.
      </xsl:message>
    </xsl:if>

    <xsl:if test="$favicon != ''">
      <link rel="icon" href="{$favicon}"/>
    </xsl:if>

    <meta name="title"><xsl:attribute name="content"><xsl:value-of select="$title"/></xsl:attribute></meta>
    <meta name="creator" content="SAO-HEA"/>
    <meta http-equiv="content-language" content="en-US"/>
    <xsl:if test="$lastmodiso != ''">
      <meta name="date" content="{$lastmodiso}"/>
    </xsl:if>
      
    <!--*
	* TODO: could add in tags/logic to set these to something more specific
	*
	* -->
    <xsl:variable name="desc"><xsl:choose>
	<xsl:when test="$site = 'ciao'">The CIAO software package for analyzing data from X-ray telescopes, including the Chandra X-ray telescope.</xsl:when>
	<xsl:when test="$site = 'sherpa'">The Sherpa package for fitting and modeling data (part of CIAO).</xsl:when>
	<xsl:when test="$site = 'chips'">The ChIPS package for plotting and imaging data (part of CIAO).</xsl:when>
	<xsl:when test="$site = 'csc'">The Chandra Source Catalog</xsl:when>
	<xsl:when test="$site = 'pog'">Help for writing proposals for the Chandra X-ray telescope.</xsl:when>
	
	<xsl:when test="$site = 'iris'">IRIS - the VAO Spectral Energy Distribution Analysis Tool</xsl:when>
	
	<xsl:otherwise>Information about the Chandra X-ray Telescope for Astronomers.</xsl:otherwise>
    </xsl:choose></xsl:variable>

    <!--* Fall backs, for the common case where pages do not have specific information *-->
    <xsl:if test="not(boolean(info/metalist/meta[@name='subject']))">
      <meta name="subject" content="{$desc}"/>
    </xsl:if>
    <xsl:if test="not(boolean(info/metalist/meta[@name='description']))">
      <meta name="description" content="{$desc}"/>
    </xsl:if>
    
    <meta name="keywords" content="SI,Smithsonian,Smithsonian Institute"/>
    <meta name="keywords" content="CfA,SAO,Harvard-Smithsonian,Center for Astrophysics"/>
    <meta name="keywords" content="HEA,HEAD,High Energy Astrophysics Division"/>

  </xsl:template> <!-- name=add-sao-metadata -->

  <!--*
      * add a ssi include statement to the output, surrounded by new lines
      * (because we are having issues with the register CGI stuff
      *  and I'm hoping that the carriage returns will improve
      *  things)
      *
      * Parameters:
      *  file - string, required
      *    the file to include
      *
      *-->
  <xsl:template name="add-ssi-include">
    <xsl:param name='file' select="''"/>

    <xsl:call-template name="check-nonempty-param">
      <xsl:with-param name="name"     select="'file'"/>
      <xsl:with-param name="value"    select="$file"/>
      <xsl:with-param name="template" select="'add-ssi-include'"/>
    </xsl:call-template>

    <xsl:call-template name="newline"/>
    <xsl:comment>#include virtual="<xsl:value-of select="$file"/>"</xsl:comment>
    <xsl:call-template name="newline"/>

  </xsl:template> <!--* name=add-ssi *-->

  <!--*
      * Add a site-specific include file, specialised for
      * iCXC and IRIS sites, others use /incl/[type].html.
      *
      * Parameters:
      *   type - string, required
      *      gives the filename (without trailing .html);
      *      should also be vao[type].html and cxc[type].html
      *      variants.
      *-->
  <xsl:template name="add-site-include">
    <xsl:param name="type" select="''"/>

    <xsl:call-template name="check-nonempty-param">
      <xsl:with-param name="name"     select="'type'"/>
      <xsl:with-param name="value"    select="$type"/>
      <xsl:with-param name="template" select="'add-site-include'"/>
    </xsl:call-template>

    <xsl:choose>
      <xsl:when test="$site='icxc'">
        <xsl:call-template name="add-ssi-include">
          <xsl:with-param name="file" select="concat('/incl/', $type, '.html')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$site='iris'">
        <xsl:call-template name="add-ssi-include">
          <xsl:with-param name="file" select="concat('/iris/vao', $type, '.html')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="add-ssi-include">
          <xsl:with-param name="file" select="concat('/incl/cxc', $type, '.html')"/>
        </xsl:call-template>
      </xsl:otherwise> 
    </xsl:choose>
  </xsl:template> <!--* name=add-site-include *-->

  <!--*
      * add the standard header, specialized for 
      * iCXC and IRIS sites, others use /incl/cxcheader.html.
      *
      * Parameters:
      *   lastmodvalue - string, required
      *
      * Also depends on the package-wide params/variables:
      *    $site, $type, $updateby, $url [kind of]
      *
      * For now we only add a "URL:" bar if the global $url
      * variable is not ''. We need to sort this out so that we
      * can have one for all pages.
      *
      *-->
  <xsl:template name="add-header">
    <xsl:param name="lastmodvalue"  select="''"/>

    <xsl:call-template name="check-nonempty-param">
      <xsl:with-param name="name"     select="'lastmodvalue'"/>
      <xsl:with-param name="value"    select="$lastmodvalue"/>
      <xsl:with-param name="template" select="'add-footer'"/>
    </xsl:call-template>

    <xsl:call-template name="add-site-include">
      <xsl:with-param name="type" select="'header'"/>
    </xsl:call-template>

   <!--* we break up into lots of different sections to try and make lynx happier *-->

    <!--*
        * this is only going to be picked up by user agents that do not process
        * stylesheets - as long as the stylesheet has a rule
        *    .hideme { display: none; }
        * so it's a good way of getting to lynx users
        *-->

    <div class="hideme">
      <a href="#navtext" accesskey="s"
	title="Skip to the navigation links">Skip to the navigation links</a>
    </div>

    <!-- *
         * Really this should be called topbar but to avoid 
         * renaming stylesheets, use the ugly name of topbarcontainer
	 *-->
    <div class="topbarcontainer">
      <!--* we do not have a search bar on the pages for site=icxc *-->
      <xsl:if test="$site != 'icxc'">
	<div class="topbar">
	  <xsl:call-template name="add-search-ssi"/>
	</div>
      </xsl:if>

      <div class="topbar">
	<div class="lastmodbar">Last modified: <xsl:value-of select="$lastmodvalue"/></div>
	<xsl:if test="$url != ''">
	  <!--* this is a safety check for now *-->
	  <br class="hideme"/>
	  <div class="urlbar">URL: <xsl:value-of select="$url"/></div>
	</xsl:if>
      </div>
    </div>
  </xsl:template> <!--* name=add-header *-->

  <!--*
      * add the standard footer, specialized for 
      * iCXC and IRIS sites, others use /incl/cxcfooter.html.
      *
      * Parameters:
      *   lastmodvalue - string, required
      *
      * Also depends on the package-wide params/variables:
      *    $site, $type
      *
      *-->
  <xsl:template name="add-footer">
    <xsl:param name="lastmodvalue"  select="''"/>

    <xsl:call-template name="check-nonempty-param">
      <xsl:with-param name="name"     select="'lastmodvalue'"/>
      <xsl:with-param name="value"    select="$lastmodvalue"/>
      <xsl:with-param name="template" select="'add-footer'"/>
    </xsl:call-template>

    <br clear="all"/>
    <div class="bottombar">
      <div class="lastmodbar">Last modified: <xsl:value-of select="$lastmodvalue"/></div>
    </div>

    <xsl:if test="($site = 'ciao' or $site = 'sherpa' or $site = 'chips' or $site = 'chart' or $site = 'obsvis' or $site = 'iris') and $type = 'live'">
      <xsl:call-template name="add-ssi-include">
        <xsl:with-param name="file" select="$googlessi"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:call-template name="add-site-include">
      <xsl:with-param name="type" select="'footer'"/>
    </xsl:call-template>

  </xsl:template> <!--* name=add-footer *-->

  <!--*
      * add the necessary SSI to get the search bar
      *-->
  <xsl:template name="add-search-ssi">
    <xsl:call-template name="add-ssi-include">
      <xsl:with-param name="file" select="$searchssi"/>
    </xsl:call-template>
  </xsl:template> <!--* add-search-ssi *-->

</xsl:stylesheet>
