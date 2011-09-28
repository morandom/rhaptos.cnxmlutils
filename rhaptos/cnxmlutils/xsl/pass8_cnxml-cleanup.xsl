<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  exclude-result-prefixes="c"
  version="1.0">

<!-- Most of these templates are "SHORTCUTS",
     meant to reduce the amount of RED XML needed in the import doc.
     For example, the text:
      <exercise>
        some text, figures, equations, etc
        <solution>A</solution>
      </exercise>
     
     translates into the following valid cnxml:
      <exercise>
        <problem>
          <para>some text</para>
          <para>figures, equations, etc</para>
        <solution>
          <para>A</para>
        </solution>
      </exercise>
     
-->

<!-- Remove all debug processing instructions -->
<xsl:template match="processing-instruction('cnx.debug')"/>

<!-- SHORTCUT: allow "<figure>title [] [] caption</figure>" to create subfigures -->
<!-- Figures cannot have para tags in them and images are converted into figures as well (so it'll be a nested figure/para/figure ) -->
<xsl:template match="c:figure[c:para]">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="c:title"/>
    <!-- Images are also converted to figures -->
    <xsl:apply-templates select="c:para/c:figure/node()"/>
    <!-- Captions and such -->
    <xsl:apply-templates select="c:para/*[not(self::c:figure)]|c:*[not(self::c:para or self::c:title)]"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="c:figure//c:figure">
  <xsl:processing-instruction name="cnx.warning">Stripping out nested figure (word import)</xsl:processing-instruction>
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- SHORTCUT: Any time there are multiple images in a c:figure wrap them in a c:subfigure -->
<xsl:template match="c:media[not(parent::c:subfigure) and count(ancestor::c:figure//c:media) &gt; 1]">
  <c:subfigure>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </c:subfigure>
</xsl:template>

<!-- SHORTCUT: allow "<glossary> <term>word</term> meaning \n ... </glossary>" -->
<xsl:template match="c:glossary/c:para">
  <c:definition>
    <xsl:apply-templates select="*[1]"/><!-- should be a term -->
    <c:meaning>
      <xsl:apply-templates select="node()[position() != 1]"/>
    </c:meaning>
  </c:definition>
</xsl:template>

<xsl:template match="c:term/text()">
  <xsl:value-of select="normalize-space(.)"/>
</xsl:template>

<!-- SHORTCUT: allow authors to just enter "<problem>a</problem>" (without exercise) -->
<xsl:template match="c:problem[not(ancestor::c:exercise)]">
  <c:exercise>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </c:exercise>
</xsl:template>

<!-- SHORTCUT: allow authors to just enter "<exercise>a</exercise>" (without problem) -->
<xsl:template match="c:exercise[not(c:problem)]">
  <!-- Assume everything except for c:solution is part of the problem -->
  <c:exercise>
    <xsl:apply-templates select="@*"/>
    <c:problem>
      <xsl:apply-templates select="node()[not(self::c:solution)]"/>
    </c:problem>
    <xsl:apply-templates select="c:solution"/>
  </c:exercise>
</xsl:template>

<!-- SHORTCUT: allow authors to just enter "<solution>a</solution>" (without para)-->
<xsl:template match="c:solution/text()">
  <c:para>
    <xsl:value-of select="."/>
  </c:para>
</xsl:template>

<xsl:template match="c:title//c:figure">
  <xsl:processing-instruction name="cnx.error">Figures in a heading is NOT allowed! Make sure the image is in a normal paragraph</xsl:processing-instruction>
</xsl:template>

<xsl:template match="c:section[count(*) &lt;= 1]">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
    <c:para>
      <xsl:processing-instruction name="cnx.warning">All headings must be followed by some content. Inserting an empty paragraph.</xsl:processing-instruction>
    </c:para>
  </xsl:copy>
</xsl:template>


<xsl:template match="c:equation/c:para">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- Footnotes with just a para can just unwrap the para -->
<xsl:template match="c:footnote[count(*) = 1 and c:para[count(*) = 0]]">
  <xsl:copy>
    <xsl:apply-templates select="@*|c:para/node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>